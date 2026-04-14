import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';
import '../widgets/shared_app_bar.dart';

class WellnessRemindersScreen extends StatefulWidget {
  final String heroTag;
  final VoidCallback? onMenuPressed;
  const WellnessRemindersScreen({super.key, this.heroTag = 'wellness_goals', this.onMenuPressed});

  @override
  State<WellnessRemindersScreen> createState() =>
      _WellnessRemindersScreenState();
}

class _WellnessRemindersScreenState extends State<WellnessRemindersScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final reminders = storage.getAllAppointments();
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: SharedAppBar(
        title: 'Wellness Goals',
        onMenuPressed: widget.onMenuPressed,
      ),
      body: Container(
        decoration: AppTheme.getBackgroundDecoration(context),
        child: Hero(
          tag: widget.heroTag,
          child: Material(
            color: Colors.transparent,
            child: reminders.isEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: kToolbarHeight + topPadding + 40),
                    child: _buildEmptyState(context, storage),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(24, kToolbarHeight + topPadding + 24, 24, 120),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return _buildReminderCard(context, storage, reminder)
                          .animate()
                          .fadeIn(delay: (index * 100).ms)
                          .slideX(begin: 0.1);
                    },
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderSheet(context, storage),
        backgroundColor: AppTheme.accentPink,
        label: Text(
          'Add Goal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildEmptyState(BuildContext context, StorageService storage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧘', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            'Keep your wellness on track',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set goals for your cycle journey.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: context.secondaryText,
            ),
          ),
          const SizedBox(height: 32),
          ThemedContainer(
            type: ContainerType.glass,
            onTap: () => _showAddReminderSheet(context, storage),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'Create First Goal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppTheme.accentPink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    StorageService storage,
    Appointment reminder,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ThemedContainer(
        type: ContainerType.glass,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                reminder.category.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, MMM d').format(reminder.date),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
              ),
              onPressed: () {
                storage.deleteAppointment(reminder);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal removed')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderSheet(BuildContext context, StorageService storage) {
    DateTime selectedDate = DateTime.now();
    String selectedTitle = '';
    WellnessCategory selectedCategory = WellnessCategory.mindfulness;
    
    final List<Map<String, dynamic>> categories = [
      {'cat': WellnessCategory.mindfulness, 'label': 'Mindfulness'},
      {'cat': WellnessCategory.movement, 'label': 'Movement'},
      {'cat': WellnessCategory.nutrition, 'label': 'Nutrition'},
      {'cat': WellnessCategory.selfCare, 'label': 'Self-Care'},
      {'cat': WellnessCategory.social, 'label': 'Social'},
      {'cat': WellnessCategory.goal, 'label': 'Goals'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setSheetState) => Container(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    MediaQuery.of(context).viewInsets.bottom + 40,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set New Wellness Goal',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Goal Title',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: context.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (val) => selectedTitle = val,
                        decoration: InputDecoration(
                          hintText: 'e.g. Morning Meditation',
                          hintStyle: TextStyle(color: context.secondaryText.withValues(alpha: 0.4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppTheme.accentPink.withValues(alpha: 0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppTheme.accentPink.withValues(alpha: 0.1)),
                          ),
                        ),
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Category',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: context.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            categories.map((item) {
                              final cat = item['cat'] as WellnessCategory;
                              final label = item['label'] as String;
                              final isSelected = selectedCategory == cat;
                              return GestureDetector(
                                onTap: () => setSheetState(() => selectedCategory = cat),
                                child: AnimatedContainer(
                                  duration: 200.ms,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? AppTheme.accentPink
                                            : AppTheme.accentPink.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(cat.emoji),
                                      const SizedBox(width: 4),
                                      Text(
                                        label,
                                        style: GoogleFonts.inter(
                                          color: isSelected ? Colors.white : AppTheme.accentPink,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Date',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: context.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ThemedContainer(
                        type: ContainerType.glass,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setSheetState(() => selectedDate = date);
                          }
                        },
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(selectedDate),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 20,
                              color: AppTheme.accentPink,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedTitle.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a goal title')),
                              );
                              return;
                            }
                            storage.saveAppointment(
                              Appointment(
                                title: selectedTitle,
                                date: selectedDate,
                                typeIndex: selectedCategory.index,
                              ),
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Goal added!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Confirm Goal'),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
