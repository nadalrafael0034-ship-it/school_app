import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/admin_provider.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Classes'),
        backgroundColor: const Color(0xFF0F0F1A),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClassDialog(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Class',
            style:
                GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: provider.isLoading && provider.classes.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              onRefresh: () => provider.fetchClasses(),
              color: AppTheme.primaryColor,
              child: provider.classes.isEmpty
                  ? ListView(children: [
                      const SizedBox(height: 120),
                      Icon(Icons.class_outlined, size: 64, color: Colors.white12),
                      const SizedBox(height: 12),
                      Center(
                          child: Text('No classes found',
                              style: GoogleFonts.poppins(color: Colors.white38))),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                      itemCount: provider.classes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final cls = provider.classes[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cls.displayName,
                                        style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      color: AppTheme.cardColor,
                                      icon: const Icon(Icons.more_vert,
                                          color: Colors.white38),
                                      onSelected: (v) async {
                                        if (v == 'delete') {
                                          final confirm = await _confirmDialog(
                                              context, 'Delete ${cls.name}?');
                                          if (confirm == true) {
                                            provider.deleteClass(cls.id);
                                          }
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(children: [
                                            Icon(Icons.delete_outline,
                                                color: AppTheme.dangerColor,
                                                size: 16),
                                            const SizedBox(width: 8),
                                            Text('Delete',
                                                style: GoogleFonts.poppins(
                                                    color: AppTheme.dangerColor)),
                                          ]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (cls.academicYear.isNotEmpty)
                                  _chip(Icons.calendar_today_outlined,
                                      cls.academicYear, Colors.white38),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: cls.subjects
                                      .map((s) => _chip(
                                          Icons.book_outlined,
                                          '${s.name} (${s.code})',
                                          AppTheme.secondaryColor))
                                      .toList(),
                                ),
                                if (cls.teachers.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    const Icon(Icons.person_outline,
                                        size: 14, color: AppTheme.teacherColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${cls.teachers.length} Teacher(s)',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.teacherColor),
                                    ),
                                  ]),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.poppins(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Future<bool?> _confirmDialog(BuildContext ctx, String msg) {
    return showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text('Confirm',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        content:
            Text(msg, style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete',
                  style: TextStyle(color: AppTheme.dangerColor))),
        ],
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final sectionCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();
    final yearCtrl = TextEditingController(text: '2024-25');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text('Add New Class',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Class Name (e.g. A)'),
                const SizedBox(height: 10),
                _dialogField(sectionCtrl, 'Section (e.g. Morning)'),
                const SizedBox(height: 10),
                _dialogField(gradeCtrl, 'Grade (e.g. 10)',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _dialogField(yearCtrl, 'Academic Year'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final success =
                  await context.read<AdminProvider>().createClass({
                'name': nameCtrl.text.trim(),
                'section': sectionCtrl.text.trim(),
                'grade': gradeCtrl.text.trim(),
                'academicYear': yearCtrl.text.trim(),
              });
              Navigator.pop(context);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Class created!'),
                    backgroundColor: AppTheme.successColor));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
