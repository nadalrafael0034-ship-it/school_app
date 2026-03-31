import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/student_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../shared/widgets/attendance_status_chip.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final recent = (provider.dashboard['recentRecords'] as List?) ?? [];
    final today = (provider.dashboard['todayRecord'] as List?) ?? [];
    final pct = provider.overallPercentage;
    final pctColor = pct >= 75
        ? AppTheme.successColor
        : pct >= 50
            ? AppTheme.warningColor
            : AppTheme.dangerColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<StudentProvider>().fetchDashboard(),
          color: AppTheme.studentColor,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello,',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.white38)),
                          Text(user?.name.split(' ').first ?? 'Student',
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          if (user?.classInfo != null)
                            Text(
                              user!.classInfo!.displayName,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.studentColor),
                            ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.studentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.studentColor.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.school_outlined,
                            color: AppTheme.studentColor, size: 22),
                      ),
                    ],
                  ),
                ),
              ),

              // Big circular indicator
              SliverToBoxAdapter(
                child: provider.isLoading && provider.dashboard.isEmpty
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: AppTheme.studentColor),
                      ))
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.cardColor,
                                pctColor.withOpacity(0.06),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: pctColor.withOpacity(0.25)),
                          ),
                          child: Row(
                            children: [
                              CircularPercentIndicator(
                                radius: 60,
                                lineWidth: 10,
                                percent: (pct / 100).clamp(0.0, 1.0),
                                center: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('$pct%',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 22)),
                                    Text('Attendance',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white38,
                                            fontSize: 10)),
                                  ],
                                ),
                                progressColor: pctColor,
                                backgroundColor: pctColor.withOpacity(0.15),
                                circularStrokeCap: CircularStrokeCap.round,
                                animation: true,
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _statRow(Icons.check_circle_outline,
                                        'Present', '${provider.overallPresent}',
                                        AppTheme.successColor),
                                    const SizedBox(height: 10),
                                    _statRow(Icons.cancel_outlined,
                                        'Absent', '${provider.overallAbsent}',
                                        AppTheme.dangerColor),
                                    const SizedBox(height: 10),
                                    _statRow(Icons.event_note_outlined,
                                        'Total', '${provider.overallTotal}',
                                        Colors.white38),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

              // Today's Record
              if (today.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: Text("Today's Attendance",
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final rec = today[i];
                        final records = rec['records'] as List? ?? [];
                        final myRec = records.isNotEmpty ? records.first : null;
                        final sub = rec['subject'] ?? {};
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(sub['name'] ?? 'N/A',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ),
                              if (myRec != null)
                                AttendanceStatusChip(
                                    status: myRec['status'] ?? 'absent'),
                            ],
                          ),
                        );
                      },
                      childCount: today.length,
                    ),
                  ),
                ),
              ],

              // Recent Records
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text('Recent Records',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: recent.isEmpty
                    ? SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                              child: Text('No records yet',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white38))),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final rec = recent[i];
                            final sub = rec['subject'] ?? {};
                            final records =
                                (rec['records'] as List?) ?? [];
                            final myStatus = records.isNotEmpty
                                ? records.first['status']
                                : 'absent';
                            final date =
                                DateTime.tryParse(rec['date'] ?? '') ??
                                    DateTime.now();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.dividerColor),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(sub['name'] ?? 'N/A',
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                        Text(
                                          DateFormat('dd MMM yyyy').format(date),
                                          style: GoogleFonts.poppins(
                                              color: Colors.white38,
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AttendanceStatusChip(status: myStatus),
                                ],
                              ),
                            );
                          },
                          childCount: recent.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
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
}
