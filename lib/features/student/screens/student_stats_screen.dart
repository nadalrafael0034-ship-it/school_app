import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/student_provider.dart';

class StudentStatsScreen extends StatefulWidget {
  const StudentStatsScreen({super.key});

  @override
  State<StudentStatsScreen> createState() => _StudentStatsScreenState();
}

class _StudentStatsScreenState extends State<StudentStatsScreen> {
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final stats = provider.stats;
    final overall = stats['overall'] ?? {};
    final subjects = (stats['subjects'] as List?) ?? [];

    final overallPresent = (overall['present'] ?? 0) as int;
    final overallAbsent = (overall['total'] ?? 0) - overallPresent;
    final overallPct = (overall['percentage'] ?? 0) as int;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('My Statistics'),
        backgroundColor: const Color(0xFF0F0F1A),
      ),
      body: provider.isLoading && stats.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.studentColor))
          : RefreshIndicator(
              onRefresh: () => provider.fetchStats(),
              color: AppTheme.studentColor,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Overall pie chart
                  if (overall.isNotEmpty && (overall['total'] ?? 0) > 0)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overall Attendance',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: Row(
                              children: [
                                Expanded(
                                  child: PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (ev, resp) {
                                          setState(() {
                                            _touchedIndex = resp?.touchedSection
                                                    ?.touchedSectionIndex ??
                                                -1;
                                          });
                                        },
                                      ),
                                      sectionsSpace: 3,
                                      centerSpaceRadius: 40,
                                      sections: [
                                        _pieSection(
                                            overallPresent.toDouble(),
                                            AppTheme.successColor,
                                            0,
                                            'Present'),
                                        _pieSection(
                                            overallAbsent.toDouble(),
                                            AppTheme.dangerColor,
                                            1,
                                            'Absent'),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _legend(AppTheme.successColor, 'Present',
                                        '$overallPresent'),
                                    const SizedBox(height: 12),
                                    _legend(AppTheme.dangerColor, 'Absent',
                                        '$overallAbsent'),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _pctColor(overallPct)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: _pctColor(overallPct)
                                                .withOpacity(0.5)),
                                      ),
                                      child: Text('$overallPct%',
                                          style: GoogleFonts.poppins(
                                              color: _pctColor(overallPct),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Subject breakdown
                  Text('Subject-wise Breakdown',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 12),

                  if (subjects.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(14)),
                      child: Center(
                          child: Text('No subject data yet',
                              style: GoogleFonts.poppins(
                                  color: Colors.white38))),
                    )
                  else
                    ...subjects.map<Widget>((sub) {
                      final subInfo = sub['subject'] ?? {};
                      final name = subInfo['name'] as String? ?? 'Unknown';
                      final code = subInfo['code'] as String? ?? '';
                      final present = sub['present'] ?? 0;
                      final absent = sub['absent'] ?? 0;
                      final late = sub['late'] ?? 0;
                      final total = sub['total'] ?? 1;
                      final pct = (sub['percentage'] ?? 0.0).toDouble();
                      final pctColor = _pctColor(pct.round());

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: pctColor.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      if (code.isNotEmpty)
                                        Text(code,
                                            style: GoogleFonts.poppins(
                                                color: Colors.white38,
                                                fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Text('${pct.round()}%',
                                    style: GoogleFonts.poppins(
                                        color: pctColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearPercentIndicator(
                              percent: (pct / 100).clamp(0.0, 1.0),
                              lineHeight: 10,
                              backgroundColor: pctColor.withOpacity(0.12),
                              progressColor: pctColor,
                              barRadius: const Radius.circular(6),
                              padding: EdgeInsets.zero,
                              animation: true,
                              animationDuration: 800,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _miniStat(Icons.check_circle_outline,
                                    '$present P', AppTheme.successColor),
                                const SizedBox(width: 10),
                                _miniStat(Icons.cancel_outlined,
                                    '$absent A', AppTheme.dangerColor),
                                const SizedBox(width: 10),
                                _miniStat(Icons.watch_later_outlined,
                                    '$late L', AppTheme.warningColor),
                                const Spacer(),
                                Text('$total classes',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white38, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  PieChartSectionData _pieSection(
      double value, Color color, int index, String title) {
    final isTouched = index == _touchedIndex;
    return PieChartSectionData(
      color: color,
      value: value,
      title: isTouched ? title : '',
      radius: isTouched ? 65 : 55,
      titleStyle: GoogleFonts.poppins(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
    );
  }

  Widget _legend(Color color, String label, String value) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label: ',
            style:
                GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
        Text(value,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ],
    );
  }

  Widget _miniStat(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: GoogleFonts.poppins(color: color, fontSize: 11)),
      ],
    );
  }

  Color _pctColor(int pct) {
    if (pct >= 75) return AppTheme.successColor;
    if (pct >= 50) return AppTheme.warningColor;
    return AppTheme.dangerColor;
  }
}
