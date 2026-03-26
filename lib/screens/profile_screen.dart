import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/neu_container.dart';
import '../widgets/brand_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Top Bar (replacing AppBar)
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => NeuContainer(
                      padding: const EdgeInsets.all(10),
                      radius: 18,
                      style: NeuStyle.convex,
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: AppTheme.accentPink,
                        size: 26,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Profile',
                        style: GoogleFonts.poppins(
                          color: AppTheme.midnightPlum,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer to balance menu button
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                child: Column(
                  children: [
                    // ── Avatar ───────────────────────────────────────────────────
                    Center(
                      child: Stack(
                        children: [
                          NeuContainer(
                            padding: const EdgeInsets.all(4),
                            radius: 50,
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: AppTheme.frameColor,
                              backgroundImage: storage.userImagePath != null
                                  ? NetworkImage(storage.userImagePath!)
                                  : null,
                              child: storage.userImagePath == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 52,
                                      color: AppTheme.accentPink,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _pickImage(context, storage),
                              child: NeuContainer(
                                padding: const EdgeInsets.all(8),
                                radius: 12,
                                style: NeuStyle.convex,
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: AppTheme.accentPink,
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

                    const SizedBox(height: 24),
                    Text(
                      storage.userName.isNotEmpty ? storage.userName : 'Guest',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 40),
                    _buildSectionTitle('Personal Info'),
                    const SizedBox(height: 16),
                    NeuContainer(
                      radius: 28,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            Icons.edit_rounded,
                            'Name',
                            storage.userName,
                            () => _editName(context, storage),
                          ),
                          _buildDivider(),
                          _buildSettingsTile(
                            Icons.cake_rounded,
                            'Age',
                            storage.userAge?.toString() ?? 'Set Age',
                            () => _editAge(context, storage),
                          ),
                          _buildDivider(),
                          _buildSettingsTile(
                            Icons.track_changes_rounded,
                            'Goal',
                            storage.userGoal == 'pregnant'
                                ? 'Track Pregnancy'
                                : (storage.userGoal == 'conceive'
                                    ? 'Conceive'
                                    : 'Track Cycle'),
                            null,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Settings'),
                    const SizedBox(height: 16),
                    NeuContainer(
                      radius: 28,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            Icons.notifications_active_rounded,
                            'Notifications',
                            'Enabled',
                            () {},
                          ),
                          _buildDivider(),
                          _buildSettingsTile(
                            Icons.security_rounded,
                            'Privacy & Security',
                            'PIN Locked',
                            () {},
                          ),
                          _buildDivider(),
                          _buildSettingsTile(
                            Icons.cloud_upload_rounded,
                            'Export Data',
                            'CSV/PDF',
                            () async {
                              final json = await storage.exportLogsToJson();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Data exported to console! (Demo mode)',
                                    ),
                                    backgroundColor: AppTheme.accentPink,
                                  ),
                                );
                                debugPrint('Exported Data: $json');
                              }
                            },
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 32),
                    _buildSectionTitle('App Info'),
                    const SizedBox(height: 16),
                    NeuContainer(
                      radius: 28,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            Icons.info_outline_rounded,
                            'Version',
                            '1.2.0 (Premium Neumorphic)',
                            null,
                          ),
                          _buildDivider(),
                          _buildSettingsTile(
                            Icons.delete_sweep_rounded,
                            'Clear All Data',
                            'Permanently erase logs',
                            () => _confirmDelete(context, storage),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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
    IconData icon,
    String title,
    String value,
    VoidCallback? onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: NeuContainer(
          padding: const EdgeInsets.all(10),
          radius: 14,
          style: NeuStyle.convex,
          child: Icon(icon, color: AppTheme.accentPink, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.shadowDark.withOpacity(0.05),
      indent: 64,
      endIndent: 24,
    );
  }

  void _editAge(BuildContext context, StorageService storage) {
    final controller = TextEditingController(
      text: storage.userAge?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.frameColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Edit Age',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        content: NeuContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          radius: 16,
          style: NeuStyle.concave,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your age',
            ),
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final age = int.tryParse(controller.text.trim());
              if (age != null) {
                storage.updateUserAge(age);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage(BuildContext context, StorageService storage) {
    final controller = TextEditingController(text: storage.userImagePath ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.frameColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Profile Image',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter an image URL for your profile picture.',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            NeuContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              radius: 16,
              style: NeuStyle.concave,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'https://example.com/image.jpg',
                ),
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                autofocus: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              storage.updateUserImagePath(null);
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                storage.updateUserImagePath(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, StorageService storage) {
    final controller = TextEditingController(text: storage.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.frameColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Edit Name',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        content: NeuContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          radius: 16,
          style: NeuStyle.concave,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your name',
            ),
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                storage.updateUserName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, StorageService storage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.frameColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Erase All Data?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All logs will be erased.',
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              storage.clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data erased.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Erase',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
