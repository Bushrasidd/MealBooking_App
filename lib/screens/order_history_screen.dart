import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'order_status_screen.dart'; // Added import for OrderStatusScreen

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService.getMyOrders();
  }

  Map<String, List<Map<String, dynamic>>> _categorizeOrdersFromApi(List<Map<String, dynamic>> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWeek = now.subtract(const Duration(days: 7));

    List<Map<String, dynamic>> recent = [];
    List<Map<String, dynamic>> lastWeekList = [];
    List<Map<String, dynamic>> history = [];

    for (var order in orders) {
      final orderDate = DateTime.parse(order['date']);
      if (orderDate.year == today.year && orderDate.month == today.month && orderDate.day == today.day) {
        recent.add(order);
      } else if (orderDate.isAfter(lastWeek)) {
        lastWeekList.add(order);
      } else {
        history.add(order);
      }
    }
    return {
      'recent': recent,
      'lastWeek': lastWeekList,
      'history': history,
    };
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.fastfood;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'lunch':
        return const Color(0xFF4CAF50);
      case 'dinner':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF667eea);
    }
  }

  String _formatDateTime(DateTime orderDateTime) {
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
    return formattedDateTime;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'delivered':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
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
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
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
                    const Text(
                      'Order History',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _ordersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Failed to load orders'));
                      }
                      final orders = snapshot.data ?? [];
                      final categorizedOrders = _categorizeOrdersFromApi(orders);

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recent Orders
                            if (categorizedOrders['recent']!.isNotEmpty) ...[
                              _buildSectionHeader('Recent Orders', Icons.access_time),
                              const SizedBox(height: 16),
                              ...categorizedOrders['recent']!.map((order) => _buildOrderCard(order)),
                              const SizedBox(height: 24),
                            ],
                            // Last Week Orders
                            if (categorizedOrders['lastWeek']!.isNotEmpty) ...[
                              _buildSectionHeader('Last Week', Icons.calendar_today),
                              const SizedBox(height: 16),
                              ...categorizedOrders['lastWeek']!.map((order) => _buildOrderCard(order)),
                              const SizedBox(height: 24),
                            ],
                            // History Orders
                            if (categorizedOrders['history']!.isNotEmpty) ...[
                              _buildSectionHeader('History', Icons.history),
                              const SizedBox(height: 16),
                              ...categorizedOrders['history']!.map((order) => _buildOrderCard(order)),
                              const SizedBox(height: 24),
                            ],
                            // Empty state
                            if (categorizedOrders['recent']!.isEmpty && 
                                categorizedOrders['lastWeek']!.isEmpty && 
                                categorizedOrders['history']!.isEmpty) ...[
                              const SizedBox(height: 60),
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF667eea).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.receipt_long,
                                        size: 60,
                                        color: Color(0xFF667eea),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No Orders Yet',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Your order history will appear here',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF718096),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667eea),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final mealType = order['order_type'] as String;
    final dateStr = order['date'] as String; // e.g., '2025-07-21'
    final timeStr = order['time'] as String? ?? '00:00'; // e.g., '15:15'
    // Combine date and time into a DateTime object
    final orderDateTime = DateTime.parse('$dateStr $timeStr');
    final orderNumber = order['order_number'] ?? order['id'];
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderStatusScreen(
              order: order, // pass the whole order map
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFF8FAFF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Meal type icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getMealColor(mealType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMealIcon(mealType),
                color: _getMealColor(mealType),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Order details
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Order $orderNumber',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              _getStatusLabel(order['status'] ?? 'pending'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: _getStatusColor(order['status'] ?? 'pending'),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getMealColor(mealType).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              mealType,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getMealColor(mealType),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(orderDateTime),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 