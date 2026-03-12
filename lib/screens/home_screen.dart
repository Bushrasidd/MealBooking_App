import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/app_decorations.dart';
import 'profile_edit_screen.dart';
import 'order_confirmation_screen.dart';
import '../services/api_service.dart'; // Added import for ApiService
import 'dart:convert'; // Added import for jsonDecode
import 'dart:async'; // Added import for Timer

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  Map<String, dynamic>? user; // <-- This must be at the top!

  bool isPressed = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _canOrder = false;
  bool _loadingOrderStatus = true;
  
  // Order status variables
  String? _currentOrderStatus;
  String? _currentOrderMessage;
  bool _showOrderStatus = false;
  Map<String, dynamic>? _currentOrder;
  


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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOrderStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    _slideController.dispose();
    _orderStatusTimer?.cancel();
    super.dispose();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (user == null) {
  //     final args = ModalRoute.of(context)!.settings.arguments;
  //     print('🏠 Home screen received arguments: $args');
  //     user = args as Map<String, dynamic>?;
  //     print('🏠 Home screen user data: $user');
  //     setState(() {});
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload data when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
      // Also refresh order status when app comes back
      _loadCurrentOrder();
    }
  }

  void _loadUserData() async {
    try {
      // Fetch fresh user data from API
      final userData = await ApiService.getProfile();
      if (userData != null && userData.isNotEmpty) {
        setState(() {
          user = userData;
        });
      }
    } catch (e) {
      // Keep existing data if API fails
    }
  }

  void _checkOrderStatus() async {
    setState(() { _loadingOrderStatus = true; });
    try {
      final hasOrdered = await ApiService.hasOrderedToday(_orderType);
      setState(() {
        _canOrder = !hasOrdered;
        _loadingOrderStatus = false;
      });
      
             // If user has ordered today, get the order details
       if (hasOrdered) {
         _loadCurrentOrder();
       }
    } catch (e) {
      setState(() { _loadingOrderStatus = false; });
    }
  }

  void _loadCurrentOrder() async {
    try {
      final orders = await ApiService.getMyOrders();
      
      if (orders != null && orders.isNotEmpty) {
        // Get today's order
        final today = DateTime.now();
        
        final todayOrder = orders.firstWhere(
          (order) {
            final orderDate = DateTime.parse(order['created_at']);
            final isToday = orderDate.year == today.year &&
                   orderDate.month == today.month &&
                   orderDate.day == today.day;
            return isToday;
          },
          orElse: () => <String, dynamic>{},
        );
        
        if (todayOrder.isNotEmpty) {
          setState(() {
            _currentOrder = todayOrder;
            _showOrderStatus = true;
            _updateOrderStatusDisplay();
          });
          // Start periodic refresh for order status
          _startOrderStatusRefresh();
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Timer? _orderStatusTimer;
  
  // Add periodic refresh for order status
  void _startOrderStatusRefresh() {
    // Cancel existing timer if any
    _orderStatusTimer?.cancel();
    
    // Refresh order status every 10 seconds (faster for testing)
    _orderStatusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadCurrentOrder();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateOrderStatusDisplay() {
    if (_currentOrder != null) {
      final rawStatus = _currentOrder!['status'];
      final status = rawStatus?.toString().toLowerCase() ?? 'pending';
      
      _currentOrderStatus = status;
      
             switch (status) {
         case 'accepted':
         case 'approved':
           _currentOrderMessage = '✅ Your order has been accepted and is being prepared!';
           break;
         case 'rejected':
           _currentOrderMessage = '❌ Your order has been rejected. Please contact admin.';
           break;
         case 'pending':
         default:
           _currentOrderMessage = '⏳ Your order is pending approval. Please wait.';
           break;
       }
      
      // Auto-hide after 3 hours
      Future.delayed(const Duration(hours: 3), () {
        if (mounted) {
          setState(() {
            _showOrderStatus = false;
          });
        }
      });
    }
  }

  void _updateOrderStatus(String status, String message) {
    setState(() {
      _currentOrderStatus = status;
      _currentOrderMessage = message;
      _showOrderStatus = true;
    });
    
    // Auto-hide status after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showOrderStatus = false;
        });
      }
    });
  }

           List<Color> _getStatusGradient(String? status) {
      switch (status) {
        case 'pending':
          return [const Color(0xFFFFB74D), const Color(0xFFFF8A65)]; // Orange gradient
        case 'accepted':
        case 'approved':
          return [const Color(0xFF4CAF50).withOpacity(0.8), const Color(0xFF66BB6A).withOpacity(0.8)]; // Transparent green gradient
        case 'rejected':
          return [const Color(0xFFFF6B6B), const Color(0xFFE57373)]; // Red gradient
        default:
          return [const Color(0xFFFFB74D), const Color(0xFFFF8A65)]; // Default orange
      }
    }

     IconData _getStatusIcon(String? status) {
     switch (status) {
       case 'pending':
         return Icons.hourglass_empty;
       case 'accepted':
       case 'approved':
         return Icons.check_circle;
       case 'rejected':
         return Icons.cancel;
       default:
         return Icons.hourglass_empty;
     }
   }





 bool get _isLunchTime {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    // Temporarily extended for testing - allows lunch orders until 18:00
    return (hour > 10 && hour < 18) || (hour == 10 && minute >= 30);
  }

  bool get _isDinnerTime {
    final now = DateTime.now();
    final hour = now.hour;
    // Temporarily extended for testing - allows dinner orders from 17:00
    return hour >= 17 && hour < 23;
  }

  // Now your getters can use `user`
  bool get _hasOrderedLunchToday {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return OrderService().hasOrderedLunchToday(user?['emp_code']);
  }
  bool get _hasOrderedDinnerToday {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return OrderService().hasOrderedDinnerToday(user?['emp_code']);
  }

  String get _orderType {
    if (_isLunchTime) return 'Lunch';
    if (_isDinnerTime) return 'Dinner';
    return '';
  }

  void _handlePlaceOrder(BuildContext context) async {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final empCode = user?['emp_code'];
    if (empCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee code not found!')),
      );
      return;
    }
    if (!_isLunchTime && !_isDinnerTime) {
      _showLunchTimeRestrictionDialog(context);
      return;
    }
    if ((_isLunchTime && _hasOrderedLunchToday) || (_isDinnerTime && _hasOrderedDinnerToday)) {
      // Already ordered, do nothing
      return;
    }
    setState(() { _loadingOrderStatus = true; });
    try {
      // Show "Placing Order" status
      _updateOrderStatus('placing', '🎯 Placing your order...');
      
      final newOrder = await ApiService.placeOrderAndReturn(
        orderType: _orderType,
        date: DateTime.now(),
      );
      
      // Show "Order Placed" status
      _updateOrderStatus('placed', '🎉 Order placed successfully! Your meal is being prepared.');
      
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(order: newOrder),
        ),
      );
      // After coming back from confirmation, show order status and re-check order status
      _updateOrderStatus('placed', '🎉 Order placed successfully! Your meal is being prepared.');
      _checkOrderStatus();
    } catch (e) {
      setState(() {
        _loadingOrderStatus = false;
        _canOrder = true;
      });

      String errorMsg = e.toString();
      // Try to extract backend error message
      RegExp regExp = RegExp(r'Failed to place order: (.*)');
      var match = regExp.firstMatch(errorMsg);
      String backendMsg = match != null ? match.group(1) ?? '' : errorMsg;

      String userMessage = 'Failed to place order';
      try {
        final decoded = jsonDecode(backendMsg);
        if (decoded is Map && decoded['detail'] != null && decoded['detail'].toString().contains('already have')) {
          userMessage = 'You have already placed a lunch order for today.';
        }
      } catch (_) {
        // fallback to string contains
        if (backendMsg.contains('already have')) {
          userMessage = 'You have already placed a lunch order for today.';
        }
      }



      // Show error status
      _updateOrderStatus('error', '❌ $userMessage');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessage)),
      );
    }
  }

  void _showLunchTimeRestrictionDialog(BuildContext context) {
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
                        Color(0xFFFF6B6B),
                        Color(0xFFFF8E53),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.08), // reduced opacity
                        blurRadius: 4, // reduced blur
                        offset: const Offset(0, 2), // slightly smaller offset
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Lunch Ordering Time',
                  style: AppTextStyles.header,
                ),
                
                const SizedBox(height: 8),
                
                                 // Message
                 Text(
                   'Lunch orders can only be placed after 12:30 PM and before 6:00 PM. Please try again later.',
                   textAlign: TextAlign.center,
                   style:  AppTextStyles.dialogMessage,
                 ),
                
                const SizedBox(height: 24),
                
                // OK Button
                Container(
                  width: double.infinity,
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
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Text(
                          'OK',
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
              ],
            ),
          ),
        );
      },
    );
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
                  style:  AppTextStyles.dialogMessage,
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

  String _getOrderWindowMessage() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    // Before lunch window
    if (hour < 12 || (hour == 12 && minute < 30)) {
      return 'Lunch orders can be placed from 12:30 PM to 6:00 PM.';
    }
    // Between lunch and dinner
    if ((hour > 18 && hour < 17) || (hour == 18 && minute >= 0 && hour < 17)) {
      return 'Dinner orders can be placed from 5:00 PM to 11:00 PM.';
    }
    // After dinner window
    if (hour >= 23) {
      return 'Ordering is closed for today. Please try again tomorrow.';
    }
    // Between lunch end and dinner start
    if (hour >= 18 && hour < 17) {
      return 'Dinner orders can be placed from 5:00 PM to 11:00 PM.';
    }
    // Fallback
    return 'Ordering is only available during lunch (12:30 PM–6:00 PM) and dinner (5:00 PM–11:00 PM).';
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    print('User object in HomeScreen: $user');
    print('user: $user');
    print('emp_code: ${user?['emp_code']}');
    
    // Store user data in state if not already stored
    if (user != null && this.user == null) {
      this.user = user;
      print('💾 Stored user data in state: $user');
    }

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
                        user: this.user ?? user,
                        isAdmin: (this.user ?? user)?['is_admin'] ?? false,
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
                  Navigator.pushNamed(context, '/order_history');
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.text),
                title: Text('Logout', style: AppTextStyles.menuItem),
                onTap: () {
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
                          child: Icon(
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
                       child: Text(
                         'Employee Details',
                         style: AppTextStyles.header,
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // Profile Card
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: AppDecorations.cardBox,
                              child: Column(
                                children: [
                                  // Profile Avatar with gradient border
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF667eea),
                                          Color(0xFF764ba2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(70),
                                    ),
                                    child: Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(66),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF667eea).withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Color(0xFF667eea),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                                                     // Employee Name
                                                                       Text(
                                      (this.user ?? user)?['name'] ?? (this.user ?? user)?['full_name'] ?? 'Employee Name',
                                      style: AppTextStyles.name,
                                    ),
                                  const SizedBox(height: 8),
                                  // Designation (show Admin/User)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF667eea).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                                                         child: Text(
                                       ((this.user ?? user)?['is_admin'] ?? false) ? 'Admin' : 'Employee',
                                       style: AppTextStyles.designation,
                                     ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Employee ID Card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF667eea).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.badge,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Employee ID',
                                                style: AppTextStyles.employeeIdLabel,
                                              ),
                                              const SizedBox(height: 4),
                                                                                             Text(
                                                 (this.user ?? user)?['emp_code'] ?? 'Emp Code',
                                                 style: AppTextStyles.employeeIdValue,
                                               ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                                                     ),
                                    const SizedBox(height: 20),
                                                                         // Order Status Container
                                     if (_showOrderStatus)
                                       GestureDetector(
                                         onTap: () {
                                           if (_currentOrder != null) {
                                             Navigator.pushNamed(
                                               context,
                                               '/order_history',
                                               arguments: _currentOrder,
                                             );
                                           }
                                         },
                                         child: Container(
                                           width: double.infinity,
                                           padding: const EdgeInsets.all(20),
                                           decoration: BoxDecoration(
                                             gradient: LinearGradient(
                                               begin: Alignment.topLeft,
                                               end: Alignment.bottomRight,
                                               colors: _getStatusGradient(_currentOrderStatus),
                                             ),
                                             borderRadius: BorderRadius.circular(16),
                                             boxShadow: [
                                               BoxShadow(
                                                 color: _getStatusGradient(_currentOrderStatus)[0].withOpacity(0.3),
                                                 blurRadius: 12,
                                                 offset: const Offset(0, 6),
                                                 spreadRadius: 1,
                                               ),
                                               BoxShadow(
                                                 color: _getStatusGradient(_currentOrderStatus)[1].withOpacity(0.2),
                                                 blurRadius: 6,
                                                 offset: const Offset(0, 3),
                                               ),
                                             ],
                                           ),
                                        child: Row(
                                          children: [
                                            // Animated icon container
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.white.withOpacity(0.2),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                _getStatusIcon(_currentOrderStatus),
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                                                                     Text(
                                                     _currentOrderStatus == 'pending' ? 'Order Pending' :
                                                     _currentOrderStatus == 'accepted' || _currentOrderStatus == 'approved' ? 'Order Accepted' :
                                                     _currentOrderStatus == 'rejected' ? 'Order Rejected' : 'Order Status',
                                                     style: AppTextStyles.employeeIdLabel.copyWith(
                                                       color: Colors.white,
                                                       fontSize: 16,
                                                       fontWeight: FontWeight.bold,
                                                     ),
                                                   ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _currentOrderMessage ?? 'Processing your request...',
                                                    style: AppTextStyles.employeeIdValue.copyWith(
                                                      color: Colors.white.withOpacity(0.9),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Status indicator
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                                                                             child: Icon(
                                                 _currentOrderStatus == 'pending' ? Icons.hourglass_empty :
                                                 _currentOrderStatus == 'accepted' || _currentOrderStatus == 'approved' ? Icons.check :
                                                 _currentOrderStatus == 'rejected' ? Icons.close :
                                                 Icons.info_outline,
                                                 color: Colors.white,
                                                 size: 14,
                                               ),
                                                                                         ),
                                           ],
                                         ),
                                       ),
                                     ),
                                   
                                  ],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                decoration: AppDecorations.buttonBox.copyWith(
                                  color: !_canOrder ? Colors.grey.shade300 : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: (_canOrder && !_loadingOrderStatus) ? () => _handlePlaceOrder(context) : null,
                                    child: Center(
                                      child: _loadingOrderStatus
                                          ? CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            )
                                          : Text(
                                              _canOrder ? 'Order Now' : 'Order Placed',
                                              style: TextStyle(
                                                color: _canOrder ? Colors.white : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
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