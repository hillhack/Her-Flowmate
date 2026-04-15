# Her-Flowmate Deployment & CI/CD Guide

This guide explains how to configure your GitHub repository to support automated, signed production builds.

## 1. Prepare Google Services
Your app requires `google-services.json` to initialize Firebase. In CI, we inject this securely from a GitHub Secret.

1.  Locate `android/app/google-services.json`.
2.  Open your terminal in the project root and run:
    ```bash
    base64 -w 0 android/app/google-services.json
    ```
3.  Copy the long string of text.

## 2. Prepare Android Signing
You need an "Upload Keystore" to sign the app.

### Generate the Keystore
Run this command once to create your persistent signing key. (Keep the password safe!):
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias upload
```

### Encode the Keystore
GitHub cannot store binary `.jks` files directly, so we encode it to base64:
```bash
base64 -w 0 android/app/upload-keystore.jks
```
Copy the long string of text.

## 3. Configure GitHub Secrets
Go to your GitHub Repository -> **Settings** -> **Secrets and variables** -> **Actions** and add these **Repository Secrets**:

| Secret Name | Value |
| :--- | :--- |
| `GOOGLE_SERVICES_JSON_BASE64` | The output from Step 1 |
| `ANDROID_KEYSTORE_BASE64` | The output from Step 2 |
| `KEYSTORE_PASSWORD` | The password you used for the keystore |
| `KEY_ALIAS` | `upload` (or whatever alias you chose) |
| `KEY_PASSWORD` | The password you used for the key |
| `API_BASE_URL` | Your production backend URL (e.g. `https://api.herflowmate.com`) |

---

## How It Works
When you push code to `main`, the CI workflow:
1.  Decodes the `GOOGLE_SERVICES_JSON_BASE64` secret back into the correct file path.
2.  Decodes the `ANDROID_KEYSTORE_BASE64` back into `upload-keystore.jks`.
3.  Creates a temporary `android/key.properties` file with your credentials.
4.  Builds the **Android App Bundle (AAB)** using `--release` and your specified `API_BASE_URL`.
5.  Uploads the signed **AAB** as a build artifact (ready for Google Play Store).
