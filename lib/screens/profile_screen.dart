import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';
import '../widgets/shared_app_bar.dart';
import 'about_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  const ProfileScreen({super.key, this.onMenuPressed});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: SharedAppBar(
        title: 'Profile',
        onMenuPressed: widget.onMenuPressed,
      ),
      body: Container(
        decoration: AppTheme.getBackgroundDecoration(context),
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isSmallScreen = screenWidth < 360;
                final hPad = isSmallScreen ? 16.0 : 24.0;
                final bottomPad = isSmallScreen ? 90.0 : 120.0;
                final avatarRadius = isSmallScreen ? 40.0 : 50.0;
                final sectionSpacing = isSmallScreen ? 24.0 : 32.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    kToolbarHeight + MediaQuery.of(context).padding.top + 24,
                    hPad,
                    bottomPad,
                  ),
                  child: Column(
                    children: [
                      // ── Avatar ───────────────────────────────────────────────────
                      Center(
                        child: Stack(
                          children: [
                            ThemedContainer(
                              type: ContainerType.glass,
                              padding: const EdgeInsets.all(6),
                              radius: avatarRadius,
                              opacity: 0.1,
                              child: Semantics(
                                label: 'Profile Picture',
                                child: CircleAvatar(
                                  radius: avatarRadius - 6,
                                  backgroundColor: AppTheme.frameColor,
                                  backgroundImage: storage.userImagePath != null
                                      ? (storage.userImagePath!.startsWith('http')
                                          ? NetworkImage(storage.userImagePath!)
                                          : FileImage(File(storage.userImagePath!)))
                                              as ImageProvider
                                      : null,
                                  child: storage.userImagePath == null
                                      ? Text(
                                          storage.userName.isNotEmpty
                                              ? storage.userName[0].toUpperCase()
                                              : 'G',
                                          style: GoogleFonts.poppins(
                                            fontSize: isSmallScreen ? 20 : 26,
                                            fontWeight: FontWeight.w800,
                                            color: context.primary,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _pickImage(context, storage),
                                child: ThemedContainer(
                                  type: ContainerType.simple,
                                  padding: const EdgeInsets.all(10),
                                  radius: 20,
                                  color: AppTheme.accentPink,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentPink
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(curve: Curves.easeOutBack),

                      SizedBox(height: isSmallScreen ? 16 : 24),
                      Text(
                        storage.userName.isNotEmpty ? storage.userName : 'Guest',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 22 : 26,
                          fontWeight: FontWeight.w800,
                          color: context.onSurface,
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      SizedBox(height: isSmallScreen ? 28 : 40),
                      _buildSectionTitle(
                        'Personal Info',
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      ThemedContainer(
                        type: ContainerType.glass,
                        width: double.infinity,
                        radius: isSmallScreen ? 24 : 32,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            _buildSettingsTile(
                              context,
                              Icons.edit_rounded,
                              'Name',
                              storage.userName,
                              () => _editName(context, storage),
                              isSmallScreen: isSmallScreen,
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              context,
                              Icons.cake_rounded,
                              'Age',
                              storage.userAge?.toString() ?? 'Set Age',
                              () => _editAge(context, storage),
                              isSmallScreen: isSmallScreen,
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              context,
                              Icons.track_changes_rounded,
                              'Goal',
                              storage.userGoal == 'pregnant'
                                  ? 'Track Pregnancy'
                                  : (storage.userGoal == 'conceive'
                                      ? 'Conceive'
                                      : 'Track Cycle'),
                              () => _showGoalSelection(context, storage),
                              isSmallScreen: isSmallScreen,
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              context,
                              Icons.monitor_weight_rounded,
                              'Weight',
                              storage.weight != null
                                  ? '${storage.weight} kg'
                                  : 'Set Weight',
                              () => _editWeight(context, storage),
                              isSmallScreen: isSmallScreen,
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              context,
                              Icons.height_rounded,
                              'Height',
                              storage.height != null
                                  ? '${storage.height} cm'
                                  : 'Set Height',
                              () => _editHeight(context, storage),
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      SizedBox(height: sectionSpacing),
                      _buildSectionTitle(
                        'App Preferences',
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      ThemedContainer(
                        type: ContainerType.glass,
                        width: double.infinity,
                        radius: isSmallScreen ? 24 : 32,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            _buildSettingsTile(
                              context,
                              Icons.notifications_active_rounded,
                              'Notifications',
                              'Enabled',
                              () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => StatefulBuilder(
                                    builder: (ctx, setModalState) => ThemedContainer(
                                      type: ContainerType.glass,
                                      padding: const EdgeInsets.all(24),
                                      radius: 32,
                                      color: context.surface,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Notification Settings',
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: context.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          SwitchListTile(
                                            title: const Text('Period Reminders'),
                                            subtitle: const Text(
                                              'Get notified before your cycle starts',
                                            ),
                                            value: storage.periodNotifications,
                                            activeThumbColor: AppTheme.accentPink,
                                            onChanged: (val) {
                                              storage.updateNotificationSettings(
                                                period: val,
                                              );
                                              setModalState(() {});
                                            },
                                          ),
                                          SwitchListTile(
                                            title: const Text('Health Check-ins'),
                                            subtitle: const Text(
                                              'Daily reminders to log symptoms',
                                            ),
                                            value: storage.healthNotifications,
                                            activeThumbColor: AppTheme.accentPink,
                                            onChanged: (val) {
                                              storage.updateNotificationSettings(
                                                health: val,
                                              );
                                              setModalState(() {});
                                            },
                                          ),
                                          const SizedBox(height: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                            _buildDivider(),
                            Consumer<StorageService>(
                              builder: (ctx, stor, _) => InkWell(
                                onTap: () => stor.toggleDarkMode(),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 12 : 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      ThemedContainer(
                                        type: ContainerType.simple,
                                        padding: EdgeInsets.all(
                                          isSmallScreen ? 8 : 10,
                                        ),
                                        radius: 20,
                                        color: AppTheme.accentPink.withValues(
                                          alpha: 0.1,
                                        ),
                                        child: Icon(
                                          stor.isDarkMode
                                              ? Icons.dark_mode_rounded
                                              : Icons.light_mode_rounded,
                                          color: AppTheme.accentPink,
                                          size: isSmallScreen ? 18 : 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Dark Mode',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: context.onSurface,
                                              ),
                                            ),
                                            Text(
                                              stor.isDarkMode ? 'On' : 'Off',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: context.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Switch(
                                        value: stor.isDarkMode,
                                        activeThumbColor: AppTheme.accentPink,
                                        onChanged: (_) => stor.toggleDarkMode(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      SizedBox(height: sectionSpacing),
                      _buildSectionTitle(
                        'Security & Data',
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      ThemedContainer(
                        type: ContainerType.glass,
                        width: double.infinity,
                        radius: isSmallScreen ? 24 : 32,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Consumer<StorageService>(
                              builder: (ctx, stor, _) => InkWell(
                                onTap: () => stor.setPinLocked(!stor.isPinLocked),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 12 : 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(
                                          isSmallScreen ? 8 : 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentPink.withValues(
                                            alpha: 0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.security_rounded,
                                          color: AppTheme.accentPink,
                                          size: isSmallScreen ? 18 : 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Privacy & Security',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: context.onSurface,
                                              ),
                                            ),
                                            Text(
                                              stor.isPinLocked ? 'Enabled' : 'Disabled',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: context.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Switch(
                                        value: stor.isPinLocked,
                                        activeThumbColor: AppTheme.accentPink,
                                        onChanged: (val) => stor.setPinLocked(val),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              context,
                              Icons.backup_rounded,
                              'Backup Data',
                              'Export / Import',
                              () => _showBackupOptions(context, storage),
                              isSmallScreen: isSmallScreen,
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              context,
                              Icons.sync_rounded,
                              'Sync with Cloud',
                              'Update logs and profile',
                              () async {
                                await storage.syncUserWithBackend();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cloud sync completed! ☁️'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              context,
                              Icons.delete_sweep_rounded,
                              'Clear All Data',
                              'Permanently erase logs',
                              () => _confirmDelete(context, storage),
                              isSmallScreen: isSmallScreen,
                              isDanger: true,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      SizedBox(height: sectionSpacing),
                      _buildSectionTitle(
                        'About',
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      ThemedContainer(
                        type: ContainerType.glass,
                        width: double.infinity,
                        radius: isSmallScreen ? 24 : 32,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            _buildSettingsTile(
                              context,
                              Icons.info_outline_rounded,
                              'Version',
                              '$_appVersion (Premium)',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AboutAppScreen(),
                                ),
                              ),
                              isSmallScreen: isSmallScreen,
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              context,
                              Icons.logout_rounded,
                              'Sign Out',
                              '',
                              () => _confirmSignOut(context, storage),
                              isSmallScreen: isSmallScreen,
                              isDanger: true,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                );
              },
            ),
            if (storage.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: ThemedContainer(
                      type: ContainerType.glass,
                      radius: 24,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentPink,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Processing...',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: context.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isSmallScreen = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: context.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    VoidCallback? onTap, {
    bool isSmallScreen = false,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: Semantics(
        label: '$title: $value',
        button: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: isDanger
                        ? Colors.redAccent.withValues(alpha: 0.1)
                        : AppTheme.accentPink.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isDanger ? Colors.redAccent : AppTheme.accentPink,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDanger ? Colors.redAccent : context.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.secondaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.accentPink,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 8,
      thickness: 1,
      color: context.onSurface.withValues(alpha: 0.1),
      indent: 64,
      endIndent: 24,
    );
  }

  void _editAge(BuildContext context, StorageService storage) {
    _ageController.text = storage.userAge?.toString() ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.frameColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: StatefulBuilder(
          builder: (ctx, setModalState) {
            String? errorText;

            void validateAndSave() {
              final ageStr = _ageController.text.trim();
              if (ageStr.isEmpty) {
                setModalState(() => errorText = 'Please enter your age');
                return;
              }
              final age = int.tryParse(ageStr);
              if (age == null || age < 5 || age > 100) {
                setModalState(
                  () => errorText = 'Please enter a valid age (5-100)',
                );
                return;
              }
              storage.updateUserAge(age);
              Navigator.pop(ctx);
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomSheetHeader('Edit Age'),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: AppTheme.glassDecoration(
                    radius: 20,
                    opacity: 0.3,
                    borderColor: errorText != null ? Colors.redAccent : null,
                  ),
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your age',
                      errorText: errorText,
                      errorStyle: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.onSurface,
                    ),
                    autofocus: true,
                    onSubmitted: (_) => validateAndSave(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: validateAndSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  child: Text(
                    'Save Age',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showGoalSelection(BuildContext context, StorageService storage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.frameColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHeader('Change Your Goal'),
            const SizedBox(height: 24),
            _goalOption(
              ctx,
              'Track my cycle',
              'Period tracking & phase predictions',
              Icons.refresh_rounded,
              'track_cycle',
              storage,
            ),
            const SizedBox(height: 12),
            _goalOption(
              ctx,
              'Trying to conceive',
              'Fertile window & ovulation tracking',
              Icons.favorite_rounded,
              'conceive',
              storage,
            ),
            const SizedBox(height: 12),
            _goalOption(
              ctx,
              'Already pregnant',
              'Pregnancy week & baby development',
              Icons.child_care_rounded,
              'pregnant',
              storage,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _goalOption(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    String goal,
    StorageService storage,
  ) {
    final isSelected = storage.userGoal == goal;
    return GestureDetector(
      onTap: () {
        storage.updateUserGoal(goal);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassDecoration(
          radius: 20,
          opacity: isSelected ? 0.4 : 0.1,
          borderColor: isSelected ? AppTheme.accentPink : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentPink.withValues(alpha: 0.1)
                    : AppTheme.textSecondary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.accentPink : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppTheme.accentPink : AppTheme.textDark,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.accentPink,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetHeader(String title) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.textDark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, StorageService storage) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.frameColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile Picture',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceOption(
                  ctx,
                  Icons.photo_library_rounded,
                  'Gallery',
                  () async {
                    Navigator.pop(ctx);
                    try {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        imageQuality: 85,
                      );
                      if (image != null) {
                        storage.updateUserImagePath(image.path);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile picture updated!'),
                              backgroundColor: AppTheme.accentPink,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not pick image: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ),
                _imageSourceOption(
                  ctx,
                  Icons.camera_alt_rounded,
                  'Camera',
                  () async {
                    Navigator.pop(ctx);
                    try {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 800,
                        imageQuality: 85,
                      );
                      if (image != null) {
                        storage.updateUserImagePath(image.path);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile picture updated!'),
                              backgroundColor: AppTheme.accentPink,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not access camera: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            if (storage.userImagePath != null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  storage.updateUserImagePath(null);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile picture removed'),
                    ),
                  );
                },
                icon: const Icon(Icons.delete_rounded, color: Colors.red),
                label: Text(
                  'Remove Picture',
                  style: GoogleFonts.inter(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accentPink.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.accentPink, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, StorageService storage) {
    _nameController.text = storage.userName;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.frameColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: StatefulBuilder(
          builder: (ctx, setModalState) {
            String? errorText;

            void validateAndSave() {
              final name = _nameController.text.trim();
              if (name.isEmpty) {
                setModalState(() => errorText = 'Name cannot be empty');
                return;
              }
              if (name.length > 30) {
                setModalState(
                  () => errorText = 'Name is too long (max 30)',
                );
                return;
              }
              storage.updateUserName(name);
              Navigator.pop(ctx);
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomSheetHeader('Edit Name'),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: AppTheme.glassDecoration(
                    radius: 20,
                    opacity: 0.3,
                    borderColor: errorText != null ? Colors.redAccent : null,
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your name',
                      errorText: errorText,
                      errorStyle: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                    autofocus: true,
                    onSubmitted: (_) => validateAndSave(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: validateAndSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  child: Text(
                    'Save Name',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, StorageService storage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.frameColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHeader('Erase All Data?'),
            const SizedBox(height: 16),
            Text(
              'This action is permanent and cannot be undone. All your period logs, daily check-ins, and health data will be completely wiped.',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        storage.clearAllData();
                        Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'All data successfully erased.',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to clear data: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Erase Data',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, StorageService storage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.frameColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHeader('Sign Out?'),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to sign out?',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await storage.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showBackupOptions(BuildContext context, StorageService storage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.frameColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.textDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Backup & Recovery',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred format for sharing or backup.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _exportOption(
              ctx,
              '📄',
              'PDF Health Report',
              'A beautifully formatted summary for sharing.',
              () async {
                Navigator.pop(ctx);
                try {
                  await storage.exportLogsToPdf();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF Export failed: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            _exportOption(
              ctx,
              '📥',
              'Import JSON Data',
              'Restore a previous JSON backup.',
              () async {
                Navigator.pop(ctx);
                try {
                  final result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                  );
                  if (result != null && result.files.isNotEmpty) {
                    final fileUrl = result.files.single.path;
                    if (fileUrl != null) {
                      final file = File(fileUrl);
                      final jsonStr = await file.readAsString();
                      await storage.importLogsFromJson(jsonStr);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Import complete! 📥'),
                          ),
                        );
                      }
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Import failed: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _exportOption(
    BuildContext context,
    String emoji,
    String title,
    String sub,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration(radius: 24, opacity: 0.5),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _editWeight(BuildContext context, StorageService storage) {
    _weightController.text = storage.weight?.toString() ?? '';
    _showNumberInputDialog(
      context,
      title: 'Update Weight',
      label: 'Weight (kg)',
      controller: _weightController,
      onSave: (val) => storage.updateWeight(val),
    );
  }

  void _editHeight(BuildContext context, StorageService storage) {
    _heightController.text = storage.height?.toString() ?? '';
    _showNumberInputDialog(
      context,
      title: 'Update Height',
      label: 'Height (cm)',
      controller: _heightController,
      onSave: (val) => storage.updateHeight(val),
    );
  }

  void _showNumberInputDialog(
    BuildContext context, {
    required String title,
    required String label,
    required TextEditingController controller,
    required Function(double) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(controller.text);
                  if (val != null) {
                    onSave(val);
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
