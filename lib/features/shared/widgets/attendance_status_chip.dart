import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AttendanceStatusChip extends StatelessWidget {
  final String status;
  const AttendanceStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStatusColor(status);
    final icon = status == 'present'
        ? Icons.check_circle_outline
        : status == 'absent'
            ? Icons.cancel_outlined
            : Icons.watch_later_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
