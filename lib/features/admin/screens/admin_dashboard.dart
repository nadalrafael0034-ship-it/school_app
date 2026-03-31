import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../shared/widgets/stat_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final stats = provider.dashboardStats['stats'] ?? {};
    final recentAttendance =
        (provider.dashboardStats['recentAttendance'] as List?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<AdminProvider>().fetchDashboard(),
          color: AppTheme.primaryColor,
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
                          Text('Welcome back,',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.white38)),
                          Text(user?.name.split(' ').first ?? 'Admin',
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.adminColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.adminColor.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.admin_panel_settings,
                            color: AppTheme.adminColor, size: 22),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats grid
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: provider.isLoading && stats.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryColor)))
                    : SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.05,
                        ),
                        delegate: SliverChildListDelegate([
                          StatCard(
                            title: 'Total Students',
                            value: '${stats['totalStudents'] ?? 0}',
                            icon: Icons.school_outlined,
                            color: AppTheme.studentColor,
                          ),
                          StatCard(
                            title: 'Total Teachers',
                            value: '${stats['totalTeachers'] ?? 0}',
                            icon: Icons.person_outline,
                            color: AppTheme.teacherColor,
                          ),
                          StatCard(
                            title: 'Active Classes',
                            value: '${stats['totalClasses'] ?? 0}',
                            icon: Icons.class_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          StatCard(
                            title: 'Subjects',
                            value: '${stats['totalSubjects'] ?? 0}',
                            icon: Icons.book_outlined,
                            color: AppTheme.accentColor,
                          ),
                        ]),
                      ),
              ),

              // Recent Attendance
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Attendance',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(height: 12),
                      if (recentAttendance.isEmpty && !provider.isLoading)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text('No attendance records yet',
                                style: GoogleFonts.poppins(
                                    color: Colors.white38)),
                          ),
                        ),
                      ...recentAttendance.map<Widget>((a) {
                        final cls = a['class'] ?? {};
                        final sub = a['subject'] ?? {};
                        final date = DateTime.tryParse(a['date'] ?? '') ??
                            DateTime.now();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.fact_check_outlined,
                                    color: AppTheme.primaryColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${cls['name'] ?? ''} (${cls['section'] ?? ''})',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      '${sub['name'] ?? 'N/A'} • ${date.day}/${date.month}/${date.year}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11, color: Colors.white38),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
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
