import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';

class WellnessRemindersScreen extends StatefulWidget {
  final String heroTag;
  const WellnessRemindersScreen({super.key, this.heroTag = 'wellness_goals'});

  @override
  State<WellnessRemindersScreen> createState() =>
      _WellnessRemindersScreenState();
}

class _WellnessRemindersScreenState extends State<WellnessRemindersScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final reminders = storage.getAllAppointments();

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Wellness Goals', style: AppTheme.playfair(fontSize: 24)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Hero(
        tag: widget.heroTag,
        child: Material(
          color: Colors.transparent,
          child:
              reminders.isEmpty
                  ? _buildEmptyState(context, storage)
                  : ListView.builder(
                    padding: const EdgeInsets.all(24),
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
      ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Set reminders for yoga, meditation, self-care days, or wellness goals.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddReminderSheet(context, storage),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            label: Text(
              'Add a Goal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPink,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildReminderCard(
    BuildContext context,
    StorageService storage,
    Appointment reminder,
  ) {
    final cat = reminder.category;
    final isPast = reminder.date.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ThemedContainer(
        type: ContainerType.neu,
        radius: 28,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(cat.emoji, style: const TextStyle(fontSize: 28)),
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
                      fontWeight: FontWeight.w800,
                      color:
                          isPast ? AppTheme.textSecondary : AppTheme.textDark,
                      decoration: isPast ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('MMM d, h:mm a').format(reminder.date),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (reminder.notes != null && reminder.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      reminder.notes!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () => _confirmDelete(context, storage, reminder),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    StorageService storage,
    Appointment reminder,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              'Delete Goal?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
            ),
            content: const Text(
              'Are you sure you want to remove this wellness reminder?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  storage.deleteAppointment(reminder);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }

  void _showAddReminderSheet(BuildContext context, StorageService storage) {
    _titleController.clear();
    _notesController.clear();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));
    WellnessCategory selectedCat = WellnessCategory.selfCare;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setModalState) => Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.frameColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    MediaQuery.of(ctx).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.neuDarkShadow,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'New Wellness Goal',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Goal Title (e.g. Morning Yoga)',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              WellnessCategory.values.map((cat) {
                                final isSelected = selectedCat == cat;
                                return GestureDetector(
                                  onTap:
                                      () => setModalState(
                                        () => selectedCat = cat,
                                      ),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? AppTheme.accentPink
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? AppTheme.accentPink
                                                : AppTheme.neuDarkShadow,
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(cat.emoji),
                                          const SizedBox(width: 6),
                                          Text(
                                            cat.label,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : AppTheme.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Reminder Date & Time',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat(
                            'EEEE, MMM d, h:mm a',
                          ).format(selectedDate),
                        ),
                        trailing: const Icon(
                          Icons.edit_calendar_rounded,
                          color: AppTheme.accentPink,
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null && context.mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDate),
                            );
                            if (time != null) {
                              setModalState(() {
                                selectedDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'Notes (optional)',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_titleController.text.trim().isEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a goal title.'),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                              return;
                            }
                            storage.saveAppointment(
                              Appointment(
                                title: _titleController.text.trim(),
                                date: selectedDate,
                                notes: _notesController.text.trim(),
                                typeIndex: selectedCat.index,
                              ),
                            );
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPink,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Save Goal',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
