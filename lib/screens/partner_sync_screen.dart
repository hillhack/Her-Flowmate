import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/storage_service.dart';
import '../services/prediction_service.dart';
import '../services/partner_service.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';

class PartnerSyncScreen extends StatefulWidget {
  const PartnerSyncScreen({super.key});

  @override
  State<PartnerSyncScreen> createState() => _PartnerSyncScreenState();
}

class _PartnerSyncScreenState extends State<PartnerSyncScreen> {
  String? _syncCode;
  bool _isLoading = false;
  int _activeTab = 0; // 0: My Code, 1: Link Partner
  final TextEditingController _connectController = TextEditingController();

  Future<void> _generateCode() async {
    setState(() => _isLoading = true);
    try {
      final result = await PartnerService.generateSyncCode();
      if (result != null) {
        setState(() {
          _syncCode = result['code'];
        });
      } else {
        _showError('Failed to generate code. Try again later.');
      }
    } catch (e) {
      _showError('Connection error.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connectWithCode() async {
    final code = _connectController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final success = await PartnerService.connectToPartner(code);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully linked with partner! ❤️')),
        );
        _connectController.clear();
      } else {
        _showError('Invalid code or connection expired.');
      }
    } catch (e) {
      _showError('Connection error.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _copyCode() {
    if (_syncCode != null) {
      Clipboard.setData(ClipboardData(text: _syncCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sync code copied to clipboard!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppTheme.accentPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final pred = context.watch<PredictionService>();
    final phase = pred.currentPhase;
    final name =
        storage.userName.isNotEmpty
            ? storage.userName.split(' ').first
            : 'Your Partner';

    String partnerMessage = '';
    switch (phase) {
      case CyclePhase.menstrual:
        partnerMessage =
            "$name is currently on her Period. Energy levels might be low. It's a great time for extra cuddles, hot tea, and bringing her favorite snacks!";
        break;
      case CyclePhase.follicular:
        partnerMessage =
            "$name is in her Follicular Phase. She's likely feeling energetic, creative, and ready to socialize. Plan a fun date out!";
        break;
      case CyclePhase.ovulation:
        partnerMessage =
            "$name is Ovulating! She's likely feeling confident, outgoing, and radiant. A perfect time for romantic evenings.";
        break;
      case CyclePhase.luteal:
        partnerMessage =
            "$name is in her Luteal Phase. She might start feeling more inward, moody, or physically tired as her period approaches. Be extra patient and supportive!";
        break;
      default:
        partnerMessage =
            "$name hasn't logged enough data yet, but today is always a good day to show her some extra love!";
        break;
    }

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Partner Sync',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.accentPink,
                      size: 64,
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Partner Connection',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  'Sync with your partner to share cycle insights and support each other through every phase.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                
                // Tab Switcher
                Container(
                  height: 56,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _activeTab == 0 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _activeTab == 0 ? [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                              ] : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'My Code',
                              style: GoogleFonts.inter(
                                fontWeight: _activeTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                color: _activeTab == 0 ? AppTheme.accentPink : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _activeTab == 1 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _activeTab == 1 ? [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                              ] : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Link Partner',
                              style: GoogleFonts.inter(
                                fontWeight: _activeTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                color: _activeTab == 1 ? AppTheme.accentPink : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms),
                
                const SizedBox(height: 24),
                ThemedContainer(
                  type: ContainerType.glass,
                  padding: const EdgeInsets.all(32),
                  radius: 32,
                  child: _activeTab == 0 ? _buildMyCodeSection() : _buildLinkPartnerSection(),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 48),
                Text(
                  'Preview: What they will see today',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 16),
                ThemedContainer(
                  type: ContainerType.glass,
                  padding: const EdgeInsets.all(24),
                  radius: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.phaseColor(
                                phase.displayName,
                              ).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wb_sunny_rounded,
                              color: AppTheme.phaseColor(phase.displayName),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$name's Phase",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  phase.displayName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.phaseColor(
                                      phase.displayName,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          partnerMessage,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textDark,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyCodeSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accentPink));
    }
    
    return Column(
      children: [
        if (_syncCode == null) ...[
          GestureDetector(
            onTap: _generateCode,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBA68C8), AppTheme.accentPink],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPink.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Generate Sync Code',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ] else ...[
          Text(
            'Your Sync Code',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.accentPink.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Text(
              _syncCode!,
              style: GoogleFonts.robotoMono(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
                letterSpacing: 4,
              ),
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _copyCode,
            icon: const Icon(Icons.copy_rounded, color: AppTheme.accentPink),
            label: Text(
              'Copy Code',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentPink,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLinkPartnerSection() {
    return Column(
      children: [
        Text(
          'Enter Partner\'s Code',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _connectController,
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoMono(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            hintText: 'XXX-XXX-XXX',
            hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.3)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.white),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _isLoading ? null : _connectWithCode,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.accentPink,
              borderRadius: BorderRadius.circular(24),
            ),
            child: _isLoading 
              ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
              : Text(
                  'Link with Partner',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
