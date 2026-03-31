import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/student_provider.dart';
import '../../shared/widgets/attendance_status_chip.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final all = provider.attendanceRecords;

    final filtered = _statusFilter == 'all'
        ? all
        : all.where((r) => r.status == _statusFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: const Color(0xFF0F0F1A),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', 'present', 'absent', 'late'].map((f) {
                  final isActive = _statusFilter == f;
                  final color = f == 'all'
                      ? AppTheme.primaryColor
                      : f == 'present'
                          ? AppTheme.successColor
                          : f == 'absent'
                              ? AppTheme.dangerColor
                              : AppTheme.warningColor;
                  return GestureDetector(
                    onTap: () => setState(() => _statusFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? color.withOpacity(0.2)
                            : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? color
                              : AppTheme.dividerColor,
                        ),
                      ),
                      child: Text(
                        f.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? color : Colors.white38,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Count badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text('${filtered.length} records',
                    style: GoogleFonts.poppins(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),

          Expanded(
            child: provider.isLoading && all.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.studentColor))
                : RefreshIndicator(
                    onRefresh: () => provider.fetchAttendance(),
                    color: AppTheme.studentColor,
                    child: filtered.isEmpty
                        ? ListView(children: [
                            const SizedBox(height: 80),
                            Icon(Icons.list_alt_outlined,
                                size: 64, color: Colors.white12),
                            const SizedBox(height: 12),
                            Center(
                                child: Text('No records found',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white38))),
                          ])
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                                16, 8, 16, 20),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final rec = filtered[i];
                              final sub = rec.subject;
                              final subName =
                                  sub?['name'] as String? ?? 'N/A';
                              final subCode =
                                  sub?['code'] as String? ?? '';
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppTheme.getStatusColor(
                                            rec.status)
                                        .withOpacity(0.2),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.getStatusColor(
                                              rec.status)
                                          .withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        rec.status == 'present'
                                            ? Icons
                                                .check_circle_outline
                                            : rec.status == 'absent'
                                                ? Icons.cancel_outlined
                                                : Icons
                                                    .watch_later_outlined,
                                        color: AppTheme.getStatusColor(
                                            rec.status),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  title: Text(subName,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  subtitle: Text(
                                    '${subCode.isNotEmpty ? "$subCode  •  " : ""}${DateFormat("EEE, dd MMM yyyy").format(rec.date)}',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white38,
                                        fontSize: 11),
                                  ),
                                  trailing: AttendanceStatusChip(
                                      status: rec.status),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
