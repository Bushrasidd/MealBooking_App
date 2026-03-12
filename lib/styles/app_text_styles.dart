import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const header = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  static const dialogTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  static const dialogMessage = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  static const menuItem = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  static const name = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  static const designation = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  static const employeeIdLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
  static const employeeIdValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const inputHint = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
  );
  static const noAccountText = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );
  static const registerText = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    fontSize: 14,
  );
  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const drawerLink = TextStyle(
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
    // decoration: TextDecoration.underline,
    fontSize: 16,
  );
}
