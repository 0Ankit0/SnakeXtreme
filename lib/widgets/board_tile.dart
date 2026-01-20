import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class BoardTile extends StatelessWidget {
  final int number;
  final bool isAlternate;

  const BoardTile({
    super.key,
    required this.number,
    this.isAlternate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isAlternate
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.backgroundLight.withValues(alpha: 0.5),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: isAlternate
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 4,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: isAlternate
                ? AppColors.textPrimary.withValues(alpha: 0.7)
                : AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
