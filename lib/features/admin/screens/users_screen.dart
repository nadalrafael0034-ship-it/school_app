import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/admin_provider.dart';
import '../../shared/widgets/role_badge.dart';
import 'add_user_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final List<String?> _roles = [null, 'student', 'teacher', 'admin'];
  final List<String> _labels = ['All', 'Students', 'Teachers', 'Admins'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        context.read<AdminProvider>().fetchUsers(role: _roles[_tabCtrl.index]);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: const Color(0xFF0F0F1A),
        bottom: TabBar(
          controller: _tabCtrl,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.white38,
          indicatorColor: AppTheme.primaryColor,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddUserScreen()),
          );
          if (result == true) {
            context.read<AdminProvider>().fetchUsers(role: _roles[_tabCtrl.index]);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label:
            Text('Add User', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: provider.isLoading && provider.users.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              onRefresh: () => provider.fetchUsers(role: _roles[_tabCtrl.index]),
              color: AppTheme.primaryColor,
              child: provider.users.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Icon(Icons.people_outline, size: 64, color: Colors.white12),
                        const SizedBox(height: 12),
                        Center(
                            child: Text('No users found',
                                style: GoogleFonts.poppins(color: Colors.white38))),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                      itemCount: provider.users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _UserCard(
                        user: provider.users[i],
                        onDeactivate: () async {
                          final confirm = await _confirmDialog(
                              context, 'Deactivate ${provider.users[i].name}?');
                          if (confirm == true) {
                            provider.deactivateUser(provider.users[i].id);
                          }
                        },
                      ),
                    ),
            ),
    );
  }

  Future<bool?> _confirmDialog(BuildContext ctx, String msg) {
    return showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text('Confirm',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Confirm',
                  style: TextStyle(color: AppTheme.dangerColor))),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDeactivate;

  const _UserCard({required this.user, required this.onDeactivate});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getRoleColor(user.role);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.5)]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(user.initials,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
        ),
        title: Text(user.name,
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(user.email,
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 4),
            RoleBadge(role: user.role),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: AppTheme.cardColor,
          icon: const Icon(Icons.more_vert, color: Colors.white38),
          onSelected: (v) {
            if (v == 'deactivate') onDeactivate();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'deactivate',
              child: Row(children: [
                Icon(Icons.block, color: AppTheme.dangerColor, size: 16),
                const SizedBox(width: 8),
                Text('Deactivate',
                    style: GoogleFonts.poppins(color: AppTheme.dangerColor)),
              ]),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
