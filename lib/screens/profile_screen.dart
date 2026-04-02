import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            decoration: AppTheme.getBackgroundDecoration(context),
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final isSmallScreen = screenWidth < 360;
                  final hPad = isSmallScreen ? 16.0 : 24.0;
                  final bottomPad = isSmallScreen ? 90.0 : 120.0;
                  final avatarRadius = isSmallScreen ? 40.0 : 50.0;
                  final sectionSpacing = isSmallScreen ? 24.0 : 32.0;
                  final topBarTop = isSmallScreen ? 16.0 : 24.0;
                  final topBarBottom = isSmallScreen ? 12.0 : 16.0;

                  return Column(
                    children: [
                      // Custom Top Bar (replacing AppBar)
                      Padding(
                        padding: EdgeInsets.only(
                          left: hPad,
                          right: hPad,
                          top: topBarTop,
                          bottom: topBarBottom,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Builder(
                                builder:
                                    (context) => ThemedContainer(
                                      type: ContainerType.glass,
                                      padding: const EdgeInsets.all(10),
                                      radius: 18,
                                      onTap:
                                          () =>
                                              Scaffold.of(context).openDrawer(),
                                      child: const Icon(
                                        Icons.menu_rounded,
                                        color: AppTheme.accentPink,
                                        size: 26,
                                      ),
                                    ),
                              ),
                            ),
                            Text(
                              'Profile',
                              style: GoogleFonts.poppins(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppTheme.darkTextPrimary
                                        : AppTheme.textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: isSmallScreen ? 18 : 22,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            hPad,
                            8,
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
                                              backgroundColor:
                                                  AppTheme.frameColor,
                                              backgroundImage:
                                                  storage.userImagePath != null
                                                      ? (storage.userImagePath!
                                                                  .startsWith(
                                                                    'http',
                                                                  )
                                                              ? NetworkImage(
                                                                storage
                                                                    .userImagePath!,
                                                              )
                                                              : FileImage(
                                                                File(
                                                                  storage
                                                                      .userImagePath!,
                                                                ),
                                                              ))
                                                          as ImageProvider
                                                      : null,
                                              child:
                                                  storage.userImagePath == null
                                                      ? Icon(
                                                        Icons.person_rounded,
                                                        size:
                                                            isSmallScreen
                                                                ? 40
                                                                : 52,
                                                        color:
                                                            AppTheme.accentPink,
                                                      )
                                                      : null,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap:
                                                () => _pickImage(
                                                  context,
                                                  storage,
                                                ),
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentPink,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppTheme.accentPink
                                                        .withValues(alpha: 0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
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
                                storage.userName.isNotEmpty
                                    ? storage.userName
                                    : 'Guest',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 22 : 26,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppTheme.darkTextPrimary
                                          : AppTheme.textDark,
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
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
                                      () =>
                                          _showGoalSelection(context, storage),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingsTile(
                                      context,
                                      Icons.notifications_active_rounded,
                                      'Notifications',
                                      'Enabled',
                                      () {},
                                      isSmallScreen: isSmallScreen,
                                    ),
                                    _buildDivider(),
                                    // Dark Mode Toggle
                                    Consumer<StorageService>(
                                      builder:
                                          (ctx, stor, _) => InkWell(
                                            onTap: () => stor.toggleDarkMode(),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    isSmallScreen ? 12 : 16,
                                                vertical: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                      isSmallScreen ? 8 : 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.accentPink
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      stor.isDarkMode
                                                          ? Icons
                                                              .dark_mode_rounded
                                                          : Icons
                                                              .light_mode_rounded,
                                                      color:
                                                          AppTheme.accentPink,
                                                      size:
                                                          isSmallScreen
                                                              ? 18
                                                              : 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Dark Mode',
                                                          style:
                                                              GoogleFonts.inter(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    AppTheme
                                                                        .textDark,
                                                              ),
                                                        ),
                                                        Text(
                                                          stor.isDarkMode
                                                              ? 'On'
                                                              : 'Off',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 12,
                                                            color:
                                                                AppTheme
                                                                    .textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Switch(
                                                    value: stor.isDarkMode,
                                                    activeThumbColor:
                                                        AppTheme.accentPink,
                                                    onChanged:
                                                        (_) =>
                                                            stor.toggleDarkMode(),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    // Biometric / PIN Lock Toggle
                                    Consumer<StorageService>(
                                      builder:
                                          (ctx, stor, _) => InkWell(
                                            onTap:
                                                () => stor.setPinLocked(
                                                  !stor.isPinLocked,
                                                ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    isSmallScreen ? 12 : 16,
                                                vertical: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                      isSmallScreen ? 8 : 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.accentPink
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.security_rounded,
                                                      color:
                                                          AppTheme.accentPink,
                                                      size:
                                                          isSmallScreen
                                                              ? 18
                                                              : 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Privacy & Security',
                                                          style:
                                                              GoogleFonts.inter(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    AppTheme
                                                                        .textDark,
                                                              ),
                                                        ),
                                                        Text(
                                                          stor.isPinLocked
                                                              ? 'Enabled'
                                                              : 'Disabled',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 12,
                                                            color:
                                                                AppTheme
                                                                    .textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Switch(
                                                    value: stor.isPinLocked,
                                                    activeThumbColor:
                                                        AppTheme.accentPink,
                                                    onChanged:
                                                        (val) => stor
                                                            .setPinLocked(val),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    ),
                                    _buildDivider(),
                                    _buildSettingsTile(
                                      context,
                                      Icons.cloud_upload_rounded,
                                      'Export Data',
                                      'CSV/PDF',
                                      () =>
                                          _showExportOptions(context, storage),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingsTile(
                                      context,
                                      Icons.info_outline_rounded,
                                      'Version',
                                      '1.2.0 (Premium)',
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => const AboutAppScreen(),
                                        ),
                                      ),
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 500.ms),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
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
                            color: AppTheme.textDark,
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
    );
  }

  Widget _buildSectionTitle(String title, {bool isSmallScreen = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
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
                // ── Leading Icon ──
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.accentPink,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
                const SizedBox(width: 16),
                // ── Title ──
                Expanded(
                  flex: 2,
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ── Trailing Value ──
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
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.textSecondary,
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
      height: 1,
      thickness: 1,
      color: AppTheme.shadowDark.withValues(alpha: 0.05),
      indent: 64,
      endIndent: 24,
    );
  }

  void _editAge(BuildContext context, StorageService storage) {
    final controller = TextEditingController(
      text: storage.userAge?.toString() ?? '',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
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
                  final ageStr = controller.text.trim();
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
                        borderColor:
                            errorText != null ? Colors.redAccent : null,
                      ),
                      child: TextField(
                        controller: controller,
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
      builder:
          (ctx) => Container(
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
                color:
                    isSelected
                        ? AppTheme.accentPink.withValues(alpha: 0.1)
                        : AppTheme.textSecondary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color:
                    isSelected ? AppTheme.accentPink : AppTheme.textSecondary,
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
                      color:
                          isSelected ? AppTheme.accentPink : AppTheme.textDark,
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
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.textDark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
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
      builder:
          (ctx) => Container(
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
    final controller = TextEditingController(text: storage.userName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
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
                  final name = controller.text.trim();
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
                        borderColor:
                            errorText != null ? Colors.redAccent : null,
                      ),
                      child: TextField(
                        controller: controller,
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
      builder:
          (ctx) => Container(
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
                            if (context.mounted) {
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

  void _showExportOptions(BuildContext context, StorageService storage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
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
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Export Health Data',
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
                  '🔧',
                  'JSON Raw Data',
                  'For developers or moving data between apps.',
                  () async {
                    Navigator.pop(ctx);
                    try {
                      final json = await storage.exportLogsToJson();
                      final dir = await getTemporaryDirectory();
                      final file = File('${dir.path}/her_flowmate_export.json');
                      await file.writeAsString(json);
                      await Share.shareXFiles([
                        XFile(file.path),
                      ], subject: 'HerFlowmate JSON Export');
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('JSON Export failed: $e')),
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
}
