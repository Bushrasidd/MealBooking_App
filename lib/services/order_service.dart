import 'package:flutter/material.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  // In-memory storage for orders (in real app, this would be a database)
  final List<Map<String, dynamic>> _orders = [];

  // Get all orders
  List<Map<String, dynamic>> getAllOrders() {
    return List.from(_orders);
  }

  // Add a new order
  void addOrder(String empCode) {
    final now = DateTime.now();
    final orderId = 'ORD 2${(_orders.length + 1).toString().padLeft(3, '0')}';
    final order = {
      'id': orderId,
      'date': now,
      'type': 'auto',
      'status': 'Pending',
      'emp_code': empCode, // Store the user's emp_code
    };
    _orders.add(order);
  }

  // Get meal type based on time
  String getMealType(DateTime orderTime) {
    final hour = orderTime.hour;
    if (hour >= 12 && hour < 17) {
      return 'Lunch';
    } else if (hour >= 17 && hour < 22) {
      return 'Dinner';
    } else if (hour >= 22 || hour < 6) {
      return 'Late Night';
    } else {
      return 'Lunch'; // Default to lunch for morning hours
    }
  }

  // Categorize orders by time period
  Map<String, List<Map<String, dynamic>>> categorizeOrders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    List<Map<String, dynamic>> recent = [];
    List<Map<String, dynamic>> lastWeek = [];
    List<Map<String, dynamic>> history = [];

    for (var order in _orders) {
      final orderDate = order['date'] as DateTime;
      final orderDay = DateTime(orderDate.year, orderDate.month, orderDate.day);
      // Add meal type to order
      order['mealType'] = getMealType(orderDate);
      if (orderDay.isAtSameMomentAs(today)) {
        recent.add(order);
      } else if (orderDay.isAfter(weekAgo)) {
        lastWeek.add(order);
      } else if (orderDay.isAfter(monthAgo)) {
        history.add(order);
      }
    }

    return {
      'recent': recent,
      'lastWeek': lastWeek,
      'history': history,
    };
  }

  // Update order status
  void updateOrderStatus(String orderId, String status) {
    for (int i = 0; i < _orders.length; i++) {
      if (_orders[i]['id'] == orderId) {
        _orders[i]['status'] = status;
        break;
      }
    }
  }

  // Get order by ID
  Map<String, dynamic>? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order['id'] == orderId);
    } catch (e) {
      return null;
    }
  }

  // Clear all orders (for testing)
  void clearOrders() {
    _orders.clear();
  }

  // Add sample orders for testing
  Future<void> addSampleOrders() async {
    if (_orders.isNotEmpty) return; // Only add if empty
    final sampleOrders = [
      {
        'id': 'ORD001',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'type': 'auto',
        'status': 'pending',
      },
      {
        'id': 'ORD002',
        'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1, 13, 30),
        'type': 'auto',
        'status': 'approved',
      },
      {
        'id': 'ORD003',
        'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 2, 19, 15),
        'type': 'auto',
        'status': 'rejected',
      },
      {
        'id': 'ORD004',
        'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 3, 18, 45),
        'type': 'auto',
        'status': 'approved',
      },
      {
        'id': 'ORD005',
        'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 8, 20, 20),
        'type': 'auto',
        'status': 'approved',
      },
      {
        'id': 'ORD006',
        'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 15, 12, 10),
        'type': 'auto',
        'status': 'rejected',
      },
      {
        'id': 'ORD007',
        'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 30, 20, 30),
        'type': 'auto',
        'status': 'approved',
      },
      {
        'id': 'ORD008',
        'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 4, 14, 15),
        'type': 'auto',
        'status': 'pending',
      },
      {
        'id': 'ORD009',
        'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 5, 17, 30),
        'type': 'auto',
        'status': 'approved',
      },
      {
        'id': 'ORD010',
        'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 6, 13, 45),
        'type': 'auto',
        'status': 'rejected',
      },
    ];
    _orders.addAll(sampleOrders);
  }

  // Check if a lunch order exists for today for a specific user
  bool hasOrderedLunchToday(String? empCode) {
    if (empCode == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var order in _orders) {
      if (order['emp_code'] != empCode) continue; // Only check this user's orders
      final orderDate = order['date'] as DateTime;
      final orderDay = DateTime(orderDate.year, orderDate.month, orderDate.day);
      if (orderDay == today) {
        final hour = orderDate.hour;
        final minute = orderDate.minute;
        final isLunch = (hour > 12 && hour < 17) || (hour == 12 && minute >= 30) || (hour == 17 && minute == 0);
        if (isLunch) {
          return true;
        }
      }
    }
    return false;
  }

  // Check if a dinner order exists for today for a specific user
  bool hasOrderedDinnerToday(String? empCode) {
    if (empCode == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var order in _orders) {
      if (order['emp_code'] != empCode) continue; // Only check this user's orders
      final orderDate = order['date'] as DateTime;
      final orderDay = DateTime(orderDate.year, orderDate.month, orderDate.day);
      if (orderDay == today) {
        final hour = orderDate.hour;
        if (hour >= 19 && hour < 23) {
          return true;
        }
      }
    }
    return false;
  }
} 