import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/teacher_provider.dart';
import '../../../data/models/class_model.dart';

class ClassReportScreen extends StatefulWidget {
  const ClassReportScreen({super.key});

  @override
  State<ClassReportScreen> createState() => _ClassReportScreenState();
}

class _ClassReportScreenState extends State<ClassReportScreen> {
  ClassModel? _selectedClass;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();
    final report = provider.classReport;
    final rows = (report['report'] as List?) ?? [];
    final totalSessions = report['totalSessions'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Class Report'),
        backgroundColor: const Color(0xFF0F0F1A),
      ),
      body: Column(
        children: [
          // Class selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DropdownButtonFormField<ClassModel>(
              value: _selectedClass,
              dropdownColor: AppTheme.cardColor,
              style:
                  GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Select Class',
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
                setState(() => _selectedClass = cls);
                if (cls != null) provider.fetchClassReport(cls.id);
              },
            ),
          ),

          if (_selectedClass == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assessment_outlined,
                        size: 64, color: Colors.white12),
                    const SizedBox(height: 12),
                    Text('Select a class to view report',
                        style:
                            GoogleFonts.poppins(color: Colors.white38)),
                  ],
                ),
              ),
            )
          else if (provider.isLoading)
            const Expanded(
              child: Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.teacherColor)),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    provider.fetchClassReport(_selectedClass!.id),
                color: AppTheme.teacherColor,
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  children: [
                    // Summary banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.teacherColor.withOpacity(0.3),
                            AppTheme.teacherColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                AppTheme.teacherColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_note,
                              color: AppTheme.teacherColor, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Sessions',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white38,
                                      fontSize: 12)),
                              Text('$totalSessions',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 28)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Student rows
                    if (rows.isEmpty)
                      Center(
                          child: Text('No attendance data yet',
                              style: GoogleFonts.poppins(
                                  color: Colors.white38)))
                    else
                      ...rows.map<Widget>((item) {
                        final student =
                            item['student'] as Map? ?? {};
                        final present = item['present'] ?? 0;
                        final absent = item['absent'] ?? 0;
                        final late = item['late'] ?? 0;
                        final total = item['total'] ?? 1;
                        final pct =
                            (item['percentage'] ?? 0.0).toDouble();
                        final pctColor = pct >= 75
                            ? AppTheme.successColor
                            : pct >= 50
                                ? AppTheme.warningColor
                                : AppTheme.dangerColor;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: pctColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      student['name'] ?? 'Unknown',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    '${pct.round()}%',
                                    style: GoogleFonts.poppins(
                                        color: pctColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LinearPercentIndicator(
                                percent: (pct / 100).clamp(0.0, 1.0),
                                lineHeight: 8,
                                backgroundColor:
                                    pctColor.withOpacity(0.15),
                                progressColor: pctColor,
                                barRadius: const Radius.circular(6),
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _mini('P', '$present',
                                      AppTheme.successColor),
                                  const SizedBox(width: 8),
                                  _mini('A', '$absent',
                                      AppTheme.dangerColor),
                                  const SizedBox(width: 8),
                                  _mini('L', '$late',
                                      AppTheme.warningColor),
                                  const Spacer(),
                                  Text('/$total sessions',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white38,
                                          fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label:$value',
          style: GoogleFonts.poppins(color: color, fontSize: 11)),
    );
  }
}
