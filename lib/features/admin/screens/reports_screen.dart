import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/admin_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedClassId;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchClasses();
      context.read<AdminProvider>().fetchReports();
    });
  }

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() => _dateRange = range);
      _applyFilters();
    }
  }

  Future<void> _applyFilters() async {
    await context.read<AdminProvider>().fetchReports(
          classId: _selectedClassId,
          startDate: _dateRange?.start.toIso8601String().substring(0, 10),
          endDate: _dateRange?.end.toIso8601String().substring(0, 10),
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final classes = provider.classes;
    final stats = provider.reports['stats'] ?? {};
    final total = (stats['totalPresent'] ?? 0) +
        (stats['totalAbsent'] ?? 0) +
        (stats['totalLate'] ?? 0);
    final presentPct = total > 0
        ? ((stats['totalPresent'] ?? 0) / total * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        backgroundColor: const Color(0xFF0F0F1A),
      ),
      body: RefreshIndicator(
        onRefresh: _applyFilters,
        color: AppTheme.primaryColor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Filter row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedClassId,
                    dropdownColor: AppTheme.cardColor,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'All Classes',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text('All Classes',
                              style: GoogleFonts.poppins(color: Colors.white))),
                      ...classes.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.displayName,
                                style:
                                    GoogleFonts.poppins(color: Colors.white)),
                          )),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedClassId = v);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Row(children: [
                      const Icon(Icons.date_range,
                          color: AppTheme.primaryColor, size: 18),
                      if (_dateRange != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${_fmt(_dateRange!.start)}\n${_fmt(_dateRange!.end)}',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Stats summary cards
            if (!provider.isLoading && stats.isNotEmpty) ...[
              Row(
                children: [
                  _summaryCard('Present', '${stats['totalPresent'] ?? 0}',
                      AppTheme.successColor, Icons.check_circle_outline),
                  const SizedBox(width: 10),
                  _summaryCard('Absent', '${stats['totalAbsent'] ?? 0}',
                      AppTheme.dangerColor, Icons.cancel_outlined),
                  const SizedBox(width: 10),
                  _summaryCard('Late', '${stats['totalLate'] ?? 0}',
                      AppTheme.warningColor,
                      Icons.watch_later_outlined),
                ],
              ),
              const SizedBox(height: 20),

              // Bar Chart
              if (total > 0)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Attendance Overview',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Overall attendance rate: $presentPct%',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.white38)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (total * 1.1).toDouble(),
                            barGroups: [
                              _bar(0, (stats['totalPresent'] ?? 0).toDouble(),
                                  AppTheme.successColor),
                              _bar(1, (stats['totalAbsent'] ?? 0).toDouble(),
                                  AppTheme.dangerColor),
                              _bar(2, (stats['totalLate'] ?? 0).toDouble(),
                                  AppTheme.warningColor),
                            ],
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: AppTheme.dividerColor,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) {
                                    const labels = ['Present', 'Absent', 'Late'];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        labels[v.toInt()],
                                        style: GoogleFonts.poppins(
                                            fontSize: 10, color: Colors.white54),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            if (provider.isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )),

            if (!provider.isLoading && stats.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text('No data available',
                      style: GoogleFonts.poppins(color: Colors.white38)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y,
        color: color,
        width: 36,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: 0,
          color: Colors.transparent,
        ),
      ),
    ]);
  }

  Widget _summaryCard(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}
