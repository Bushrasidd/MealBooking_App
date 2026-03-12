import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/app_decorations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final bool isAdmin;
  final String? userType;
  
  ProfileEditScreen({
    Key? key,
    this.user,
    this.isAdmin = false,
    this.userType,
  }) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoadingProfile = true;
  bool _isSaving = false; // Add loading state for save button

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAndSetProfile();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }
  void _fetchAndSetProfile() async {
  setState(() {
    _isLoadingProfile = true; // Add this line
  });
  
  try {
    final profile = await ApiService.getProfile();
    setState(() {
      _nameController.text = profile['full_name'] ?? '';
      _emailController.text = profile['email'] ?? '';
      _phoneController.text = profile['phone_number'] ?? '';
      _departmentController.text = profile['department'] ?? '';
      _employeeIdController.text = profile['emp_code'] ?? '';
      _isLoadingProfile = false; // Add this line
    });
  } catch (e) {
    setState(() {
      _isLoadingProfile = false; // Add this line
    });
    // Handle error, show a message, etc.
  }
}

  // void _fetchAndSetProfile() async {
  //   try {
  //     final profile = await ApiService.getProfile();
  //     setState(() {
  //       _nameController.text = profile['full_name'] ?? '';
  //       _emailController.text = profile['email'] ?? '';
  //       _phoneController.text = profile['phone_number'] ?? '';
  //       _departmentController.text = profile['department'] ?? '';
  //       _employeeIdController.text = profile['emp_code'] ?? '';
  //     });
  //   } catch (e) {
  //     // Handle error, show a message, etc.
  //   }
  // }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoadingProfile 
            ? _buildLoadingScreen()
            : _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Column(
      children: [
        // Header with back button and title
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
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
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 150,
                  child: Text(
                    widget.isAdmin ? 'Admin Profile' : 'Employee Profile',
                    style: AppTextStyles.header,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 48,
              ),
            ],
          ),
        ),
        
        // Loading content
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: AppDecorations.cardBox,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child:CircularProgressIndicator()
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Header with back button and title
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
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
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 150,
                  child: Text(
                    widget.isAdmin ? 'Admin Profile' : 'Employee Profile',
                    style: AppTextStyles.header,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(),
              // Refresh button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isLoadingProfile = true;
                  });
                  _fetchAndSetProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Refreshing profile...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
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
                    Icons.refresh,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Main content
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: AppDecorations.cardBox,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Avatar Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppDecorations.cardBox,
                    child: Column(
                      children: [
                        // Profile Avatar with gradient border
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppDecorations.mainGradient,
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Form Fields (minimal, stable)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: AppDecorations.cardBox,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Personal Information', style: AppTextStyles.sectionTitle),
                              const SizedBox(height: 20),
                              _buildStableTextField(_nameController, 'Full Name', Icons.person),
                              const SizedBox(height: 16),
                              _buildStableTextField(_emailController, 'Email Address', Icons.email, keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 16),
                              _buildStableTextField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
                              const SizedBox(height: 16),
                              _buildStableTextField(_departmentController, 'Department', Icons.business),
                              const SizedBox(height: 16),
                              _buildStableTextField(_employeeIdController, 'Employee ID', Icons.badge, isReadOnly: true),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Save Button (minimal, stable)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: AppDecorations.buttonBox.copyWith(
                              color: _isSaving ? Colors.grey.withOpacity(0.3) : null,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _isSaving ? null : () async {
                                  setState(() {
                                    _isSaving = true;
                                  });
                                  
                                  try {
                                    final updatedProfile = {
                                      'full_name': _nameController.text,
                                      'email': _emailController.text,
                                      'phone_number': _phoneController.text,
                                      'department': _departmentController.text,
                                      // emp_code is usually not editable
                                    };
                                    await ApiService.updateProfile(updatedProfile);
                                    
                                    // Get fresh user data after successful update
                                    final freshUserData = await ApiService.getProfile();
                                    
                                    // Update SharedPreferences with fresh data
                                    if (freshUserData != null && freshUserData.isNotEmpty) {
                                      await ApiService.setUserData(freshUserData);
                                      print('✅ Updated SharedPreferences with fresh user data: $freshUserData');
                                    }
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Profile updated!')),
                                    );
                                    
                                    // Return true to indicate successful update
                                    Navigator.of(context).pop(true);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to update profile')),
                                    );
                                  } finally {
                                    setState(() {
                                      _isSaving = false;
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: AppDecorations.primaryGradient,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: _isSaving
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.save,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isSaving ? 'Saving...' : 'Save Changes',
                                      style: AppTextStyles.buttonText,
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStableTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    bool isReadOnly = false,
  }) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Text(
              label, 
              style: AppTextStyles.label,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: isReadOnly,
              textAlign: TextAlign.left,
              style: AppTextStyles.body.copyWith(
                color: isReadOnly ? Colors.grey : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isReadOnly ? Colors.grey.withOpacity(0.1) : Colors.white,
                prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
                prefixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 40),
                border: AppDecorations.textFieldBorder,
                enabledBorder: AppDecorations.textFieldBorder,
                focusedBorder: AppDecorations.textFieldFocusedBorder,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: AppTextStyles.body,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 