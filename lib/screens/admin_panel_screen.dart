import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/app_decorations.dart';
import 'order_details_screen.dart';
import '../services/api_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Future<List<Map<String, dynamic>>> _allOrdersFuture;

  @override
  void initState() {
    super.initState();
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
    _allOrdersFuture = ApiService.getAllOrders();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header with profile icon
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
                            width: 120,
                            child: Text(
                              'Order List',
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
                      // Refresh button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _allOrdersFuture = ApiService.getAllOrders();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Refreshing order list...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
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
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.black87,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider line
                Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
                const SizedBox(height: 20),
                // Orders List
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _allOrdersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Failed to load orders'));
                      }
                      final orders = snapshot.data ?? [];
                      if (orders.isEmpty) {
                        return const Center(
                          child: Text(
                            'No orders found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return GestureDetector(
                            onTap: () {
                              final employeeName = order['emp_name'] ?? '';
                              final employeeCode = order['emp_id'] ?? '';
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsScreen(
                                    order: order,
                                    employeeName: employeeName,
                                    employeeCode: employeeCode,
                                  ),
                                ),
                              );
                            },
                            child: _buildRestaurantOrderCard(order),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.header.copyWith(fontSize: 24, color: color),
          ),
          Text(
            title,
            style: AppTextStyles.inputHint.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantOrderCard(Map<String, dynamic> order) {
    // Combine date and time fields for accurate DateTime
    final dateStr = order['date'] as String? ?? '';
    final timeStr = order['time'] as String? ?? '00:00';
    DateTime orderDate;
    try {
      orderDate = DateTime.parse('$dateStr $timeStr');
    } catch (_) {
      orderDate = DateTime.now();
    }
    // Use backend meal type if available
    final mealType = (order['order_type'] ?? '').toString().toLowerCase();
    final userName = order['emp_name'] ?? '';
    final orderNumber = order['order_number'] ?? order['id'];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Name
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Food Image and Details
          Container(
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: _getGradientColors(mealType),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Food illustration
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
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
                ),
                // Order details
                Positioned(
                  left: 16,
                  top: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType[0].toUpperCase() + mealType.substring(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(orderDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Status indicator (no extra padding or alignment)
                      Padding(
                        padding: const EdgeInsets.only(left: 1), // Adjust this value as needed
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: _getStatusBackgroundColor(order['status']),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(order['status']),
                                color: order['status'] == 'approved' || order['status'] == 'pending'
                                    ? Colors.white
                                    : _getStatusTextColor(order['status']),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusLabel(order['status']),
                                style: TextStyle(
                                  color: order['status'] == 'approved' || order['status'] == 'pending'
                                      ? Colors.white
                                      : _getStatusTextColor(order['status']),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'lunch':
        return Colors.orange;
      case 'dinner':
        return Colors.purple;
      case 'late night':
        return Colors.indigo;
      default:
        return Colors.grey;
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



  // Helper method to format date and time
  String _formatDateTime(DateTime dateTime) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    // Convert to Indian Standard Time (UTC +5:30)
    final istDateTime = dateTime.add(Duration(hours: 5, minutes: 30));
    
    // Convert to 12-hour format with AM/PM
    final hour = istDateTime.hour;
    final minute = istDateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final formattedTime = '${hour12}:${minute.toString().padLeft(2, '0')} $period';
    
    return '${monthNames[istDateTime.month - 1]}, ${istDateTime.day} at $formattedTime';
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'approved':
        return 'Accepted';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'delivered':
        return 'Delivered';
      default:
        return status ?? '';
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${order['id']}'),
            Text('Type: ${order['type']}'),
            Text('Meal: ${order['order_type'] ?? 'Unknown'}'),
            Text('Date: ${_formatDateTime(DateTime.parse(order['date'].toString()))}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

Color _getStatusTextColor(String? status) {
  switch (status) {
    case 'approved':
      return Colors.green;
    case 'pending':
      return Colors.lightBlue; // or Colors.cyan
    case 'rejected':
      return Colors.red;
    default:
      return Colors.white;
  }
}

IconData _getStatusIcon(String? status) {
  switch (status) {
    case 'approved':
      return Icons.check_circle;
    case 'pending':
      return Icons.hourglass_top;
    case 'rejected':
      return Icons.cancel;
    default:
      return Icons.info;
  }
}

Color _getStatusBackgroundColor(String? status) {
  switch (status) {
    case 'approved':
      return Colors.green;
    case 'pending':
      return const Color(0xFFFFB74D); // Darker yellow (Material orange[300])
    case 'rejected':
      return Colors.white;
    default:
      return Colors.white;
  }
} 