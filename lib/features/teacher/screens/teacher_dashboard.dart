import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/teacher_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../shared/widgets/stat_card.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final dashboard = provider.dashboard;
    final classes = (dashboard['classes'] as List?) ?? [];
    final todayAttendance = (dashboard['todayAttendance'] as List?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<TeacherProvider>().fetchDashboard(),
          color: AppTheme.teacherColor,
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
                          Text('Good ${_greeting()},',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.white38)),
                          Text(user?.name.split(' ').first ?? 'Teacher',
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.teacherColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.teacherColor.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.person_outline,
                            color: AppTheme.teacherColor, size: 22),
                      ),
                    ],
                  ),
                ),
              ),

              // Today's date
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.teacherColor),
                  ),
                ),
              ),

              // Stats Row
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: provider.isLoading && dashboard.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.teacherColor))
                      : Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'My Classes',
                                value:
                                    '${dashboard['totalClasses'] ?? 0}',
                                icon: Icons.class_outlined,
                                color: AppTheme.teacherColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'My Students',
                                value:
                                    '${dashboard['totalStudents'] ?? 0}',
                                icon: Icons.people_outline,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: "Today's",
                                value:
                                    '${dashboard['todayAttendanceCount'] ?? 0}',
                                icon: Icons.fact_check_outlined,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // My Classes
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('My Classes',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final cls = classes[i];
                      final subjects =
                          (cls['subjects'] as List?)?.cast<Map>() ?? [];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppTheme.teacherColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.teacherColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                  child: Icon(Icons.class_,
                                      color: AppTheme.teacherColor, size: 22)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${cls['name']} (${cls['section']})',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  if (subjects.isNotEmpty)
                                    Text(
                                      subjects
                                          .map((s) => s['name'])
                                          .join(', '),
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.white38),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: classes.length,
                  ),
                ),
              ),

              // Today's Attendance
              if (todayAttendance.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Text("Today's Attendance",
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final att = todayAttendance[i];
                        final cls = att['class'] ?? {};
                        final sub = att['subject'] ?? {};
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.successColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppTheme.successColor, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                '${cls['name'] ?? ''} • ${sub['name'] ?? ''}',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: todayAttendance.length,
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
