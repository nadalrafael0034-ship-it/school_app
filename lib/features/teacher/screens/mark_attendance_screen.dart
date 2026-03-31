import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/teacher_provider.dart';
import '../../../data/models/class_model.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: const Color(0xFF0F0F1A),
        actions: [
          if (provider.selectedClass != null &&
              provider.selectedClassStudents.isNotEmpty)
            TextButton.icon(
              onPressed: provider.isLoading ? null : _submit,
              icon: const Icon(Icons.save_outlined,
                  color: AppTheme.teacherColor, size: 18),
              label: Text('Submit',
                  style: GoogleFonts.poppins(
                      color: AppTheme.teacherColor,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Step 1: Choose Class ──────────────────────────────────
            _sectionHeader('1', 'Select Class'),
            const SizedBox(height: 10),
            DropdownButtonFormField<ClassModel>(
              value: provider.selectedClass,
              dropdownColor: AppTheme.cardColor,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Choose Class',
                prefixIcon: Icon(Icons.class_outlined,
                    color: AppTheme.teacherColor, size: 20),
              ),
              items: provider.myClasses
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.displayName,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (cls) {
                if (cls == null) return;
                provider.selectClass(cls);
                provider.fetchClassStudents(cls.id);
              },
            ),

            // ── Step 2: Choose Subject ────────────────────────────────
            if (provider.selectedClass != null) ...[
              const SizedBox(height: 16),
              _sectionHeader('2', 'Select Subject'),
              const SizedBox(height: 10),
              DropdownButtonFormField<SubjectModel>(
                value: provider.selectedSubject,
                dropdownColor: AppTheme.cardColor,
                style:
                    GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Choose Subject',
                  prefixIcon: Icon(Icons.book_outlined,
                      color: AppTheme.teacherColor, size: 20),
                ),
                items: provider.selectedClass!.subjects
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text('${s.name} (${s.code})',
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (s) => provider.selectSubject(s),
              ),

              // ── Step 3: Choose Date ───────────────────────────────────
              const SizedBox(height: 16),
              _sectionHeader('3', 'Date'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: provider.attendanceDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (ctx, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                            primary: AppTheme.teacherColor),
                      ),
                      child: child!,
                    ),
                  );
                  if (d != null) provider.setAttendanceDate(d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppTheme.teacherColor, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy')
                            .format(provider.attendanceDate),
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ── Step 4: Student List ──────────────────────────────────
            if (provider.selectedSubject != null) ...[
              const SizedBox(height: 20),
              _sectionHeader('4', 'Mark Students'),
              const SizedBox(height: 4),

              // Bulk actions
              Row(
                children: [
                  _bulkBtn('All Present', AppTheme.successColor, () {
                    for (final s in provider.selectedClassStudents) {
                      provider.updateStudentStatus(s.id, 'present');
                    }
                  }),
                  const SizedBox(width: 8),
                  _bulkBtn('All Absent', AppTheme.dangerColor, () {
                    for (final s in provider.selectedClassStudents) {
                      provider.updateStudentStatus(s.id, 'absent');
                    }
                  }),
                ],
              ),
              const SizedBox(height: 12),

              if (provider.isLoading)
                const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.teacherColor))
              else if (provider.selectedClassStudents.isEmpty)
                Center(
                    child: Text('No students in this class',
                        style:
                            GoogleFonts.poppins(color: Colors.white38)))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.selectedClassStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final student = provider.selectedClassStudents[i];
                    final record = provider.attendanceRecords
                        .firstWhere((r) => r.studentId == student.id,
                            orElse: () => throw Exception());
                    return _StudentAttendanceCard(
                      name: student.name,
                      roll: student.rollNumber,
                      initials: student.initials,
                      status: record.status,
                      onStatusChanged: (s) =>
                          provider.updateStudentStatus(student.id, s),
                    );
                  },
                ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.teacherColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(step,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }

  Widget _bulkBtn(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final provider = context.read<TeacherProvider>();
    final success = await provider.submitAttendance();
    if (mounted) {
      if (success) {
        setState(() => _submitted = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Attendance submitted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        provider.resetAttendanceForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Submission failed'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }
}

class _StudentAttendanceCard extends StatelessWidget {
  final String name;
  final String? roll;
  final String initials;
  final String status;
  final ValueChanged<String> onStatusChanged;

  const _StudentAttendanceCard({
    required this.name,
    this.roll,
    required this.initials,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initials,
                  style: GoogleFonts.poppins(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          // Name & Roll
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                if (roll != null)
                  Text('Roll: $roll',
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          // Status toggle
          _StatusToggle(status: status, onChanged: onStatusChanged),
        ],
      ),
    );
  }

  Color _borderColor() {
    if (status == 'present') return AppTheme.successColor;
    if (status == 'absent') return AppTheme.dangerColor;
    return AppTheme.warningColor;
  }
}

class _StatusToggle extends StatelessWidget {
  final String status;
  final ValueChanged<String> onChanged;

  const _StatusToggle({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn('P', 'present', AppTheme.successColor),
        const SizedBox(width: 4),
        _btn('A', 'absent', AppTheme.dangerColor),
        const SizedBox(width: 4),
        _btn('L', 'late', AppTheme.warningColor),
      ],
    );
  }

  Widget _btn(String label, String value, Color color) {
    final isActive = status == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(isActive ? 1 : 0.3)),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: isActive ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
        ),
      ),
    );
  }
}
