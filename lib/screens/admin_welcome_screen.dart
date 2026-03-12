import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/app_decorations.dart';
import 'profile_edit_screen.dart';
import '../services/api_service.dart';

class AdminWelcomeScreen extends StatefulWidget {
  const AdminWelcomeScreen({super.key});

  @override
  State<AdminWelcomeScreen> createState() => _AdminWelcomeScreenState();
}

class _AdminWelcomeScreenState extends State<AdminWelcomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload data when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  void _loadUserData() async {
    try {
      // Fetch fresh user data from API
      final userData = await ApiService.getProfile();
      if (userData != null && userData.isNotEmpty) {
        setState(() {
          _userData = userData;
        });
        print('🔄 Admin welcome screen reloaded user data: $userData');
      }
    } catch (e) {
      print('❌ Failed to reload user data: $e');
      // Keep existing data if API fails
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: AppDecorations.dialogBox,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with gradient background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Logout',
                  style: AppTextStyles.header.copyWith(color: AppColors.textPrimary),
                ),
                
                const SizedBox(height: 8),
                
                // Message
                Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.dialogMessage,
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Logout Button
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF667eea),
                              Color(0xFF764ba2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              Navigator.of(context).pop();
                              await ApiService.logout();
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Center(
                              child: Text(
                                'Logout',
                                style: AppTextStyles.buttonText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    // Use state variable if available, otherwise use route arguments
    final displayUser = _userData ?? user;
    print('Admin user info: $displayUser');
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        width: 180, // Increased width
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Profile Section
                             GestureDetector(
                 onTap: () async {
                   Navigator.pop(context);
                   final result = await Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => ProfileEditScreen(
                         user: displayUser,
                         isAdmin: displayUser?['is_admin'] ?? false,
                       ),
                     ),
                   );
                   // Refresh data when returning from profile edit
                   if (result == true) {
                     _loadUserData();
                   }
                 },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF667eea),
                              Color(0xFF764ba2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Profile',
                        style: AppTextStyles.drawerLink,
                      ),
                    ],
                  ),
                ),
              ),
              
              const Divider(),
              
              // Menu Section
              // const Divider(),
              ListTile(
                leading: Icon(Icons.shopping_bag, color: AppColors.text),
                title: Text('Orders', style: AppTextStyles.menuItem),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_panel');
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.text),
                title: Text('Logout', style: AppTextStyles.menuItem),
                onTap: () async {
                  Navigator.pop(context);
                  _showLogoutConfirmation(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppDecorations.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header with menu and title
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                                         const Spacer(),
                     FadeTransition(
                       opacity: _fadeAnimation,
                       child: Center(
                         child: Container(
                           width: 120,
                           child: Text(
                             'Admin',
                             style: AppTextStyles.header,
                             textAlign: TextAlign.center,
                           ),
                         ),
                       ),
                     ),
                     const Spacer(),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: AppDecorations.cardBox,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            
                            // Profile Card
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.08),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.12),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Profile Avatar with enhanced gradient border
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF667eea),
                                          Color(0xFF764ba2),
                                          Color(0xFF667eea),
                                        ],
                                        stops: [0.0, 0.5, 1.0],
                                      ),
                                      borderRadius: BorderRadius.circular(75),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF667eea).withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      height: 130,
                                      width: 130,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(69),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF667eea).withOpacity(0.2),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 65,
                                        color: Color(0xFF667eea),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 28),
                                  
                                                                     // Employee Name with enhanced styling
                                   Text(
                                                                           displayUser?['full_name'] ?? displayUser?['name'] ?? displayUser?['first_name'] ?? 'Admin Name',
                                     style: AppTextStyles.name.copyWith(
                                       fontSize: 26,
                                       fontWeight: FontWeight.w700,
                                       letterSpacing: 0.3,
                                     ),
                                   ),
                                   // Debug: Show user data
                                  //  if (user != null) ...[
                                  //    Text(
                                  //     //  'Debug: User data: ${user.toString()}',
                                  //     //  style: TextStyle(fontSize: 10, color: Colors.red),
                                  //    ),
                                  //  ],
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Enhanced Designation Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF667eea),
                                          Color(0xFF764ba2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF667eea).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Admin',
                                      style: AppTextStyles.designation.copyWith(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 36),
                                  
                                  // Enhanced Employee ID Card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF667eea).withOpacity(0.1),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.08),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF667eea),
                                                Color(0xFF764ba2),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF667eea).withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.badge,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Employee ID',
                                                style: AppTextStyles.employeeIdLabel.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                                                                 displayUser?['emp_code'] ?? 'Emp Code',
                                                style: AppTextStyles.employeeIdValue.copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Enhanced Next Button
                            Container(
                              width: double.infinity,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667eea).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF667eea).withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/admin_panel',
                                                                             arguments: displayUser, // Pass user info as arguments
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('View Orders', style: AppTextStyles.buttonText.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
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