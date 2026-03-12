import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static final mainGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  static final primaryGradient = const LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
  );

  // Use as: decoration: BoxDecoration(gradient: AppDecorations.mainGradient)

  static final dialogGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.card, AppColors.background],
  );

  static final dialogBox = BoxDecoration(
    color: Colors.white.withOpacity(0.95),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.015),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
    ],
  );

  static final cardBox = BoxDecoration(
    gradient: dialogGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.03),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
      BoxShadow(
        color: AppColors.shadowWhite.withOpacity(0.1),
        blurRadius: 4,
        offset: Offset(0, -1),
      ),
    ],
  );

  static final illustrationBox = BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.06),
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  );

  static final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: AppColors.border,
      width: 1,
    ),
  );

  static final inputFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: AppColors.primary,
      width: 2,
    ),
  );

  static final textFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: AppColors.border,
      width: 1,
    ),
  );

  static final textFieldFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: AppColors.primary,
      width: 2,
    ),
  );

  static final profileAvatar = BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(66),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowBlue.withOpacity(0.3),
        blurRadius: 15,
        offset: Offset(0, 5),
      ),
    ],
  );

  static final buttonBox = BoxDecoration(
    gradient: mainGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowBlue.withOpacity(0.2),
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );
}
