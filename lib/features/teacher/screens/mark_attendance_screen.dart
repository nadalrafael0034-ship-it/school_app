import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:school_attendance/data/models/attendance_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/teacher_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/class_model.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final teacherProvider = context.read<TeacherProvider>();
      // Tell provider who the logged-in teacher is
      teacherProvider.setCurrentUserId(authProvider.currentUser?.id);
      teacherProvider.fetchMyClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();
    final classTeacherClasses = provider.classTeacherClasses;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Morning Attendance',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            Text(
              DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppTheme.teacherColor),
            ),
          ],
        ),
      ),
      body: provider.isLoading && provider.myClasses.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.teacherColor))
          : classTeacherClasses.isEmpty
              ? _NotClassTeacherView()
              : _AttendanceBody(classTeacherClasses: classTeacherClasses),
    );
  }
}

// ─── View shown when teacher has no class teacher assignments ─────────────────
class _NotClassTeacherView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.teacherColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.how_to_reg_outlined,
                  color: AppTheme.teacherColor, size: 38),
            ),
            const SizedBox(height: 20),
            Text('Not a Class Teacher',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'You have not been assigned as a class teacher.\nOnly the class teacher can take morning roll call.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.white38, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main attendance body ─────────────────────────────────────────────────────
class _AttendanceBody extends StatelessWidget {
  final List<ClassModel> classTeacherClasses;
  const _AttendanceBody({required this.classTeacherClasses});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Column(
      children: [
        // Class selector (only if class teacher of multiple classes)
        if (classTeacherClasses.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: DropdownButtonFormField<ClassModel>(
              value: provider.selectedClass,
              dropdownColor: AppTheme.cardColor,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Select Your Class',
                labelStyle:
                    GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.class_outlined,
                    color: AppTheme.teacherColor, size: 20),
              ),
              items: classTeacherClasses
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.displayName,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (cls) {
                if (cls == null) return;
                context.read<TeacherProvider>().selectClass(cls);
              },
            ),
          )
        else if (classTeacherClasses.length == 1 &&
            provider.selectedClass == null)
          // Auto-select the single class
          Builder(builder: (ctx) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ctx.read<TeacherProvider>().selectClass(classTeacherClasses.first);
            });
            return const SizedBox.shrink();
          }),

        // Content
        Expanded(
          child: provider.selectedClass == null
              ? _SelectClassHint()
              : provider.isLoading || provider.checkingToday
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.teacherColor))
                  : provider.todayAlreadySubmitted
                      ? _AlreadySubmittedView(cls: provider.selectedClass!)
                      : _StudentAttendanceList(),
        ),
      ],
    );
  }
}

// ─── Hint shown before class is selected ─────────────────────────────────────
class _SelectClassHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined,
              color: AppTheme.teacherColor.withOpacity(0.4), size: 48),
          const SizedBox(height: 12),
          Text('Select your class above',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }
}

// ─── Already submitted state ──────────────────────────────────────────────────
class _AlreadySubmittedView extends StatelessWidget {
  final ClassModel cls;
  const _AlreadySubmittedView({required this.cls});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: AppTheme.successColor, size: 44),
            ),
            const SizedBox(height: 20),
            Text('Attendance Submitted!',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'Morning roll call for\n${cls.displayName}\nhas already been taken today.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.white54, height: 1.6),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Student list with Present / Absent checkboxes ────────────────────────────
class _StudentAttendanceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();
    final students = provider.selectedClassStudents;
    final records = provider.attendanceRecords;

    if (students.isEmpty) {
      return Center(
        child: Text('No students in this class',
            style: GoogleFonts.poppins(color: Colors.white38)),
      );
    }

    // Count stats
    final presentCount = records.where((r) => r.status == 'present').length;
    final absentCount = records.where((r) => r.status == 'absent').length;

    return Column(
      children: [
        // ── Stats bar ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatPill(
                    label: 'Total',
                    value: students.length,
                    color: AppTheme.teacherColor),
                _divider(),
                _StatPill(
                    label: 'Present',
                    value: presentCount,
                    color: AppTheme.successColor),
                _divider(),
                _StatPill(
                    label: 'Absent',
                    value: absentCount,
                    color: AppTheme.dangerColor),
              ],
            ),
          ),
        ),

        // ── Bulk buttons ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              _BulkButton(
                label: 'All Present',
                color: AppTheme.successColor,
                icon: Icons.check_circle_outline,
                onTap: () {
                  for (final s in provider.selectedClassStudents) {
                    provider.updateStudentStatus(s.id, 'present');
                  }
                },
              ),
              const SizedBox(width: 8),
              _BulkButton(
                label: 'All Absent',
                color: AppTheme.dangerColor,
                icon: Icons.cancel_outlined,
                onTap: () {
                  for (final s in provider.selectedClassStudents) {
                    provider.updateStudentStatus(s.id, 'absent');
                  }
                },
              ),
            ],
          ),
        ),

        // ── Student list ─────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: students.length,
            itemBuilder: (_, i) {
              final student = students[i];
              final record = records.firstWhere(
                (r) => r.studentId == student.id,
                orElse: () => AttendanceRecord(
                    studentId: student.id, status: 'present'),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _StudentRow(
                  index: i + 1,
                  name: student.name,
                  roll: student.rollNumber,
                  initials: student.initials,
                  status: record.status,
                  onPresent: () =>
                      provider.updateStudentStatus(student.id, 'present'),
                  onAbsent: () =>
                      provider.updateStudentStatus(student.id, 'absent'),
                ),
              );
            },
          ),
        ),

        // ── Submit button (pinned at bottom) ─────────────────────
        _SubmitBar(provider: provider),
      ],
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withOpacity(0.08),
      );
}

// ─── Single student row ───────────────────────────────────────────────────────
class _StudentRow extends StatelessWidget {
  final int index;
  final String name;
  final String? roll;
  final String initials;
  final String status;
  final VoidCallback onPresent;
  final VoidCallback onAbsent;

  const _StudentRow({
    required this.index,
    required this.name,
    this.roll,
    required this.initials,
    required this.status,
    required this.onPresent,
    required this.onAbsent,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = status == 'present';
    final isAbsent = status == 'absent';

    final borderColor = isPresent
        ? AppTheme.successColor.withOpacity(0.45)
        : AppTheme.dangerColor.withOpacity(0.45);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isPresent
            ? AppTheme.successColor.withOpacity(0.05)
            : AppTheme.dangerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Serial number
          SizedBox(
            width: 24,
            child: Text(
              '$index',
              style: GoogleFonts.poppins(
                  color: Colors.white30,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initials,
                  style: GoogleFonts.poppins(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 10),
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
                  Text('Roll No. $roll',
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          // Present checkbox
          _CheckTile(
            label: 'Present',
            isChecked: isPresent,
            activeColor: AppTheme.successColor,
            onTap: onPresent,
          ),
          const SizedBox(width: 8),
          // Absent checkbox
          _CheckTile(
            label: 'Absent',
            isChecked: isAbsent,
            activeColor: AppTheme.dangerColor,
            onTap: onAbsent,
          ),
        ],
      ),
    );
  }
}

// ─── Checkbox tile (radio-style: only one can be active) ─────────────────────
class _CheckTile extends StatelessWidget {
  final String label;
  final bool isChecked;
  final Color activeColor;
  final VoidCallback onTap;

  const _CheckTile({
    required this.label,
    required this.isChecked,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isChecked ? activeColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isChecked ? activeColor : Colors.white24,
            width: isChecked ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isChecked
                  ? Icon(Icons.check_box,
                      key: const ValueKey('checked'),
                      color: activeColor,
                      size: 16)
                  : Icon(Icons.check_box_outline_blank,
                      key: const ValueKey('unchecked'),
                      color: Colors.white30,
                      size: 16),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isChecked ? activeColor : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats pill ───────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11, color: Colors.white38)),
      ],
    );
  }
}

// ─── Bulk action button ───────────────────────────────────────────────────────
class _BulkButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _BulkButton(
      {required this.label,
      required this.color,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 15),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pinned submit bar ────────────────────────────────────────────────────────
class _SubmitBar extends StatelessWidget {
  final TeacherProvider provider;
  const _SubmitBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        border:
            Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : () => _submit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.teacherColor,
              disabledBackgroundColor: AppTheme.teacherColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: provider.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fact_check_outlined,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('Submit Attendance',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final success = await provider.submitAttendance();
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Morning attendance submitted successfully!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Submission failed. Please try again.'),
          backgroundColor: AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
