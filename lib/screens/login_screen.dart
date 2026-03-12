import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/app_decorations.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool isPressed = false;
  bool _isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _empCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    _fadeController.dispose();
    _slideController.dispose();
    _empCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final empCode = _empCodeController.text.trim();
    final password = _passwordController.text.trim();
    
    if (empCode.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both employee code and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🚀 Starting login process...');
      // Call the API service for login
      final response = await ApiService.login(empCode, password);
      
      print('📋 Login response received: $response');
      // Check if login was successful
      if (response['access_token'] != null) {
        // Store user data for auto-login
        final user = response['user'] ?? {};
        print('🔐 Login response user data: $user');
        await ApiService.setUserData(user);
        
        // Check if user is admin based on database fields
        final isAdmin = user['is_admin'] == true || 
               user['is_superuser'] == true || 
               user['role'] == 'admin' ||
               user['role'] == 'superuser';
        
        if (isAdmin) {
          print('🔄 Navigating to admin welcome screen');
          print('Passing user to admin_welcome: ${response['user']}');
          Navigator.pushReplacementNamed(
            context,
            '/admin_welcome',
            arguments: response['user'],
          );
        } else {
          print('🔄 Navigating to home screen');
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: response['user'], // Pass the user info from the login response
          );
        }
      } else {
        print('❌ Login failed - no access token in response');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('💥 Login error caught: $e');
      String userMessage = 'Login failed. Please try again.';
      // Try to extract backend error message
      final errorStr = e.toString();
      RegExp regExp = RegExp(r'{"detail":"([^"]+)"}');
      var match = regExp.firstMatch(errorStr);
      if (match != null) {
        userMessage = match.group(1)!;
      } else if (errorStr.contains('Incorrect employee code or password')) {
        userMessage = 'Incorrect employee code or password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppDecorations.mainGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: AppDecorations.cardBox,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Company Logo
                        // Image.asset(
                        //   'assets/images/logo2.png',
                        //   height: 100,
                        //   width: 220,
                        //   fit: BoxFit.contain,
                        // ),
                        const SizedBox(height: 16),
                        Text(
                          'Employee Login',
                          style: AppTextStyles.header,
                        ),
                        const SizedBox(height: 24),
                        // Placeholder for illustration
                        Container(
                          height: 120,
                                                     decoration: AppDecorations.illustrationBox,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/login.jpg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _empCodeController,
                          decoration: InputDecoration(
                            hintText: 'Emp Code',
                            filled: true,
                            fillColor: AppColors.white,
                            border: AppDecorations.inputBorder,
                            enabledBorder: AppDecorations.inputBorder,
                            focusedBorder: AppDecorations.inputFocusedBorder,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            hintStyle: AppTextStyles.inputHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: AppColors.white,
                            border: AppDecorations.inputBorder,
                            enabledBorder: AppDecorations.inputBorder,
                            focusedBorder: AppDecorations.inputFocusedBorder,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            hintStyle: AppTextStyles.inputHint,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Login button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: AppDecorations.buttonBox,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _isLoading ? null : _handleLogin,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isLoading)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.login,
                                          color: AppColors.white,
                                          size: 20,
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isLoading ? 'Logging in...' : 'Login',
                                      style: AppTextStyles.buttonText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(height: 16),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       'No Account yet ?',
                        //       style: AppTextStyles.noAccountText,
                        //     ),
                        //     TextButton(
                        //       onPressed: () {
                        //         Navigator.pushNamed(context, '/register');
                        //       },
                        //       child: Text(
                        //         'Register',
                        //         style: AppTextStyles.registerText,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // No social login section here!
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 