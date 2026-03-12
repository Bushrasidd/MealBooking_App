import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Load access token from SharedPreferences first
    await ApiService.loadAccessToken();
    if (ApiService.accessToken != null) {
      try {
        // Always fetch fresh user data from API for auto-login
        print('🔄 Fetching fresh user data from API...');
        final profileUser = await ApiService.getProfile();
        print('📋 Fresh Profile API response: $profileUser');
        
        // Update SharedPreferences with fresh data
        if (profileUser != null && profileUser.isNotEmpty) {
          await ApiService.setUserData(profileUser);
          print('✅ Updated SharedPreferences with fresh data');
        }
        
        final orders = await ApiService.getMyOrders();

        // Check if user is admin based on role or is_admin field from database
        final isAdmin = profileUser['is_admin'] == true || 
                       profileUser['is_superuser'] == true || 
                       profileUser['role'] == 'admin' ||
                       profileUser['role'] == 'superuser';
        if (isAdmin) {
          Navigator.pushReplacementNamed(
            context,
            '/admin_welcome',
            arguments: profileUser, // Pass the fresh user data
          );
        } else {
          print('🔄 Splash screen passing to home: $profileUser');
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: profileUser, // Pass the fresh user data
          );
        }
      } catch (e) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
} 