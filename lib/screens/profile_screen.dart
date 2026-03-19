import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // ── Avatar ───────────────────────────────────────────────────
              Center(
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  radius: 36,
                  child: const Icon(Icons.person_rounded, size: 64, color: AppTheme.accentPink),
                ),
              ).animate().fadeIn(duration: 600.ms).scale(curve: Curves.easeOutBack),

              const SizedBox(height: 24),
              Text(
                storage.userName.isNotEmpty ? storage.userName : 'Guest',
                style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 40),
              _buildSectionTitle('Personal Info'),
              const SizedBox(height: 16),
              GlassContainer(
                radius: 28,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildSettingsTile(Icons.edit_rounded, 'Name', storage.userName, () => _editName(context, storage)),
                    _buildDivider(),
                    _buildSettingsTile(Icons.track_changes_rounded, 'Goal', storage.userGoal == 'pregnant' ? 'Track Pregnancy' : (storage.userGoal == 'conceive' ? 'Conceive' : 'Track Cycle'), null),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 32),
              _buildSectionTitle('Settings'),
              const SizedBox(height: 16),
              GlassContainer(
                radius: 28,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildSettingsTile(Icons.notifications_active_rounded, 'Notifications', 'Enabled', () {}),
                    _buildDivider(),
                    _buildSettingsTile(Icons.security_rounded, 'Privacy & Security', 'PIN Locked', () {}),
                    _buildDivider(),
                    _buildSettingsTile(Icons.cloud_upload_rounded, 'Export Data', 'CSV/PDF', () async {
                      final json = await storage.exportLogsToJson();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data exported to console! (Demo mode)'), backgroundColor: AppTheme.accentPink),
                        );
                        debugPrint('Exported Data: $json');
                      }
                    }),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 32),
              _buildSectionTitle('App Info'),
              const SizedBox(height: 16),
              GlassContainer(
                radius: 28,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildSettingsTile(Icons.info_outline_rounded, 'Version', '1.2.0 (Glassmorphism Beta)', null),
                    _buildDivider(),
                    _buildSettingsTile(Icons.delete_sweep_rounded, 'Clear All Data', 'Permanently erase logs', () => _confirmDelete(context, storage)),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String value, VoidCallback? onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.accentPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppTheme.accentPink, size: 22),
      ),
      title: Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.1),
      indent: 64,
      endIndent: 20,
    );
  }

  void _editName(BuildContext context, StorageService storage) {
    final nameController = TextEditingController(text: storage.userName);
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: GlassContainer(
            radius: 28,
            width: 320,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Name', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(height: 20),
                Container(
                  decoration: AppTheme.glassDecoration(radius: 16, opacity: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: nameController,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Your name'),
                    autofocus: true,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isNotEmpty) {
                            storage.updateUserName(nameController.text.trim());
                            Navigator.pop(ctx);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPink,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text('Save', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, StorageService storage) {
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: GlassContainer(
            radius: 28,
            width: 320,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delete All Data?', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(height: 12),
                Text('This action cannot be undone. All cycle logs will be permanently erased.', 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, height: 1.4)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          storage.deleteAllLogs();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared.'), backgroundColor: Colors.redAccent));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text('Delete', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
