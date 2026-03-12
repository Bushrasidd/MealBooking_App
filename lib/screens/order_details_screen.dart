import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/app_decorations.dart';
import '../services/order_service.dart';
import '../services/api_service.dart'; // Added this import for ApiService

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String employeeName;
  final String employeeCode;
  
  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.employeeName,
    required this.employeeCode,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Order service instance
  final OrderService _orderService = OrderService();
  
  // Order status state
  String _orderStatus = 'pending'; // pending, approved, rejected
  bool _isLoadingStatus = true; // Track loading state
  bool _isProcessingRequest = false; // Track if API request is in progress
  bool _isLoadingData = true; // Track if initial data is loading

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
    
    // Load current order status from service
    _loadOrderStatus();
  }
  
  void _loadOrderStatus() async {
    setState(() {
      _isLoadingStatus = true;
    });
    
    try {
      // Fetch the latest order status from the API
      final orderData = await ApiService.getOrderById(widget.order['id']);
      if (orderData != null && orderData.isNotEmpty) {
        final status = orderData['status'] ?? 'pending';
        setState(() {
          _orderStatus = status;
          _isLoadingStatus = false;
        });
      } else {
        // If API returns null or empty, fallback to local data
        _loadFromLocalData();
      }
    } catch (e) {
      // Fallback to local data if API fails
      _loadFromLocalData();
    }
  }

  void _loadFromLocalData() {
    final order = _orderService.getOrderById(widget.order['id']);
    if (order != null) {
      setState(() {
        _orderStatus = order['status'] ?? 'pending';
        _isLoadingStatus = false;
      });
    } else {
      // If no local data either, use the passed order data
      setState(() {
        _orderStatus = widget.order['status'] ?? 'pending';
        _isLoadingStatus = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _acceptOrder() {
    setState(() {
      _orderStatus = 'approved';
    });
    // Update status in the service
    _orderService.updateOrderStatus(widget.order['id'], 'approved');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order Accepted!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectOrder() {
    setState(() {
      _orderStatus = 'rejected';
    });
    // Update status in the service
    _orderService.updateOrderStatus(widget.order['id'], 'rejected');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order Rejected!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getMealType() {
    final mealType = (widget.order['order_type'] ?? 'Unknown').toString();
    // Convert to proper case: LUNCH -> Lunch, DINNER -> Dinner
    if (mealType.toLowerCase() == 'lunch') {
      return 'Lunch';
    } else if (mealType.toLowerCase() == 'dinner') {
      return 'Dinner';
    } else if (mealType.toLowerCase() == 'late night') {
      return 'Late Night';
    } else {
      return mealType; // Keep original if not recognized
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'late night':
        return Icons.nightlife;
      default:
        return Icons.restaurant;
    }
  }

  List<Color> _getGradientColors(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'lunch':
        return [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)];
      case 'dinner':
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case 'late night':
        return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
      default:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final mealType = _getMealType();
    final employeeName = widget.employeeName;
    final employeeCode = widget.employeeCode;
    final orderNumber = widget.order['order_number'] ?? widget.order['id'];
    final dateStr = widget.order['date'] as String? ?? '';
    final timeStr = widget.order['time'] as String? ?? '12:00';
    DateTime orderDateTime;
    try {
      orderDateTime = DateTime.parse('$dateStr $timeStr');
    } catch (_) {
      orderDateTime = DateTime.now();
    }
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    // Convert to 12-hour format with AM/PM
    final hour = orderDateTime.hour;
    final minute = orderDateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final formattedTime = '${hour12}:${minute.toString().padLeft(2, '0')} $period';
    
    final formattedDateTime = '${monthNames[orderDateTime.month - 1]}, ${orderDateTime.day} at $formattedTime';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                                         Expanded(
                       child: Center(
                         child: Container(
                           width: 150,
                            child: Text(
                             'Order Details',
                             style: AppTextStyles.header.copyWith(
                               color: Colors.black87,
                               fontSize: 20,
                               fontWeight: FontWeight.bold,
                             ),
                             textAlign: TextAlign.center,
                           ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!_isLoadingStatus) {
                          _loadOrderStatus(); // Refresh order status
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Refreshing order status...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: _isLoadingStatus 
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black87,
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              color: Colors.black87,
                              size: 24,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Banner Section
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // Banner Image with Order Type
                      Container(
                        height: 200,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: _getGradientColors(mealType),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getGradientColors(mealType)[0].withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Background Pattern
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -30,
                              bottom: -30,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                            
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  // Left side - Text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          mealType,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Order Details',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Right side - Icon
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Icon(
                                      _getMealTypeIcon(mealType),
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Order Details Card
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  'Order Information',
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Order Details
                                _buildDetailRow('Order Type', mealType, Icons.restaurant_menu),
                                const SizedBox(height: 16),
                                _buildDetailRow('Employee Name', employeeName, Icons.person),
                                const SizedBox(height: 16),
                                _buildDetailRow('Order Number', orderNumber, Icons.receipt),
                                const SizedBox(height: 16),
                                _buildDetailRow('Date & Time', formattedDateTime, Icons.access_time),
                                const SizedBox(height: 16),
                                // Removed Employee Code display since emp_id removed from orders table
                                
                                const SizedBox(height: 30),
                                
                                // Accept/Reject Buttons
                                if (_isLoadingStatus) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.grey, // Subtle color
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Loading order status...',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (_orderStatus == 'pending') ...[
                                  Text(
                                    'Order Action',
                                    style: AppTextStyles.sectionTitle.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      // Accept Button
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.green,
                                                Color(0xFF4CAF50),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Opacity(
                                              opacity: _isProcessingRequest ? 0.6 : 1.0,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(12),
                                                onTap: _isProcessingRequest ? null : () => _changeOrderStatus(widget.order['id'], 'approved'),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Accept',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Reject Button
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.red,
                                                Color(0xFFE53935),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Opacity(
                                              opacity: _isProcessingRequest ? 0.6 : 1.0,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(12),
                                                onTap: _isProcessingRequest ? null : () => _changeOrderStatus(widget.order['id'], 'rejected'),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.cancel,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Reject',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
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
                                  const SizedBox(height: 24),
                                ],
                                
                                // Status Section
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _getStatusGradientColors(),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _getStatusBorderColor(),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _getStatusGradientColors(),
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getStatusIcon(),
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
                                              'Order Status',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _getStatusText(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                                                 // Conditional Action Button
                                 if (_orderStatus != 'pending') ...[
                                  const SizedBox(height: 24),
                                  Container(
                                    width: double.infinity,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _getActionButtonColors(),
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getActionButtonShadowColor(),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: _orderStatus == 'approved' ? _processOrder : _notifyRejection,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _getActionButtonIcon(),
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              _getActionButtonText(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667eea),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods for status management
  List<Color> _getStatusGradientColors() {
    switch (_orderStatus) {
      case 'approved':
        return [Colors.green.withOpacity(0.1), const Color(0xFF4CAF50).withOpacity(0.1)];
      case 'rejected':
        return [Colors.red.withOpacity(0.1), const Color(0xFFE53935).withOpacity(0.1)];
      default:
        return [const Color(0xFF667eea).withOpacity(0.1), const Color(0xFF764ba2).withOpacity(0.1)];
    }
  }

  Color _getStatusBorderColor() {
    switch (_orderStatus) {
      case 'approved':
        return Colors.green.withOpacity(0.3);
      case 'rejected':
        return Colors.red.withOpacity(0.3);
      default:
        return const Color(0xFF667eea).withOpacity(0.2);
    }
  }

  IconData _getStatusIcon() {
    switch (_orderStatus) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _getStatusText() {
    switch (_orderStatus) {
      case 'approved':
        return 'Order Accepted';
      case 'rejected':
        return 'Order Rejected';
      default:
        return 'Pending Review';
    }
  }

  List<Color> _getActionButtonColors() {
    switch (_orderStatus) {
      case 'approved':
        return [Colors.green, const Color(0xFF4CAF50)];
      case 'rejected':
        return [Colors.red, const Color(0xFFE53935)];
      default:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
  }

  Color _getActionButtonShadowColor() {
    switch (_orderStatus) {
      case 'approved':
        return Colors.green.withOpacity(0.4);
      case 'rejected':
        return Colors.red.withOpacity(0.4);
      default:
        return const Color(0xFF667eea).withOpacity(0.4);
    }
  }

  IconData _getActionButtonIcon() {
    switch (_orderStatus) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _getActionButtonText() {
    switch (_orderStatus) {
      case 'approved':
        return 'Accepted';
      case 'rejected':
        return 'Order is rejected';
      default:
        return 'Order is pending';
    }
  }

  void _processOrder() {
    // Empty method - no message, just keeps hover effect
  }

  void _notifyRejection() {
    // Empty method - no message, just keeps hover effect
  }

  void _changeOrderStatus(String orderId, String newStatus) async {
    setState(() {
      _isProcessingRequest = true; // Disable buttons
    });
    
    try {
      await ApiService.updateOrderStatus(orderId, newStatus);
      setState(() {
        _orderStatus = newStatus; // Update local status for UI
        _isProcessingRequest = false; // Re-enable buttons
      });
      // Also update the local order service
      _orderService.updateOrderStatus(orderId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated!')),
      );
    } catch (e) {
      setState(() {
        _isProcessingRequest = false; // Re-enable buttons on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order status')),
      );
    }
  }
} 