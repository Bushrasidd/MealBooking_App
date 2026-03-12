import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/app_decorations.dart';
import '../services/order_service.dart';

class OrderStatusScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderStatusScreen({Key? key, required this.order}) : super(key: key);

  // Helper method to format date and time
  String _formatDateTime(String? dateTimeString, String? timeString) {
    if (dateTimeString == null && timeString == null) return '--:--';
    
    if (dateTimeString != null) {
      // Parse the updated_at timestamp
      try {
        final dateTime = DateTime.parse(dateTimeString);
        
        // Convert to Indian Standard Time (UTC +5:30)
        final istDateTime = dateTime.add(Duration(hours: 5, minutes: 30));
        
        final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        
        final hour = istDateTime.hour;
        final minute = istDateTime.minute;
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final formattedTime = '${hour12}:${minute.toString().padLeft(2, '0')} $period';
        
        return '${monthNames[istDateTime.month - 1]}, ${istDateTime.day} at $formattedTime';
      } catch (e) {
        return '--:--';
      }
    } else if (timeString != null) {
      // Use the time column for pending orders
      return timeString;
    }
    
    return '--:--';
  }

  @override
  Widget build(BuildContext context) {
    final String currentStatus = order['status']; // 'pending', 'approved', 'rejected', 'delivered'

    List<Map<String, dynamic>> statusSteps = [
      {
        'label': 'Pending',
        'icon': Icons.access_time,
        'color': Color(0xFFFFCA28), // Light yellow (Material yellow[200])
        'description': 'Order placed and waiting for approval.',
        'status': 'pending',
        'time': _formatDateTime(order['created_at'], null), // Use created_at for pending
      },
    ];

    if (currentStatus == 'approved' || currentStatus == 'delivered') {
      statusSteps.add({
        'label': 'Accepted',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'description': 'Order accepted and being prepared.',
        'status': 'approved',
        'time': _formatDateTime(order['updated_at'], null), // Use updated_at for approved
      });
    }
    if (currentStatus == 'rejected') {
      statusSteps.add({
        'label': 'Rejected',
        'icon': Icons.cancel,
        'color': Colors.red,
        'description': 'Order rejected by cafeteria.',
        'status': 'rejected',
        'time': _formatDateTime(order['updated_at'], null), // Use updated_at for rejected
      });
    }
    if (currentStatus == 'delivered') {
      statusSteps.add({
        'label': 'Delivered',
        'icon': Icons.restaurant,
        'color': Colors.purple,
        'description': 'Order delivered to you.',
        'status': 'delivered',
        'time': order['delivered_time'] ?? '--:--',
      });
    } else {
      // Always show Delivered as inactive at the end, unless already delivered
      statusSteps.add({
        'label': 'Delivered',
        'icon': Icons.restaurant,
        'color': Colors.grey, // Inactive color
        'description': 'Order delivered to you.',
        'status': 'delivered',
        'time': '--:--',
      });
    }

    final List<String> statusOrder = ['pending', 'approved', 'rejected', 'delivered'];
    final int currentIndex = statusOrder.indexOf(currentStatus);
    final double animationDuration = 1.0; // seconds per step

    List<Widget> buildTimeline() {
      return List.generate(statusSteps.length, (index) {
        final step = statusSteps[index];
        final isActive = index <= currentIndex;
        final isCurrent = index == currentIndex;

        // Determine if the connector below should be colored or gray
        bool connectorActive = false;
        if (index < currentIndex && currentStatus != 'rejected' && currentStatus != 'delivered') {
          connectorActive = true;
        } else if (index < currentIndex && (currentStatus == 'rejected' || currentStatus == 'delivered')) {
          // Only color up to the current step, then gray
          connectorActive = index < currentIndex - 1;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator with glow for current
              Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isActive ? step['color'] : Colors.grey[300],
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [BoxShadow(color: step['color'].withOpacity(0.5), blurRadius: 16, spreadRadius: 2)]
                          : [],
                      border: Border.all(
                        color: isCurrent ? step['color'] : Colors.grey[300]!,
                        width: 2, // fixed width for all
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      step['icon'],
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (index != statusSteps.length - 1)
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: connectorActive ? step['color'] : Colors.grey[300],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Status details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['label'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isActive ? step['color'] : Colors.grey,
                        fontSize: isCurrent ? 18 : 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['time'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      step['description'],
                      style: TextStyle(
                        color: isActive ? Colors.black87 : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    }

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
                      'Order Status',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 48,
                    ), // Placeholder for symmetry
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Vertically center
                    children: [
                      Center(
                        child: Container(
                          width: 450,
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Order Status',
                                style: AppTextStyles.header.copyWith(color: AppColors.primary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Order Number: ${order['order_number'] ?? order['id']}',
                                style: AppTextStyles.body,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: currentIndex.toDouble()),
                                duration: Duration(milliseconds: 600 * (currentIndex + 1)),
                                builder: (context, value, child) {
                                  return Column(
                                    children: List.generate(statusSteps.length, (index) {
                                      final step = statusSteps[index];
                                      final isActive = index <= value.round();
                                      final isCurrent = index == value.round();

                                      // Determine if the connector below should be colored or gray
                                      bool connectorActive = false;
                                      if (index < value.round() && currentStatus != 'rejected' && currentStatus != 'delivered') {
                                        connectorActive = true;
                                      } else if (index < value.round() && (currentStatus == 'rejected' || currentStatus == 'delivered')) {
                                        // Only color up to the current step, then gray
                                        connectorActive = index < value.round() - 1;
                                      }

                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Timeline indicator with glow for current
                                            Column(
                                              children: [
                                                AnimatedContainer(
                                                  duration: Duration(milliseconds: 300),
                                                  decoration: BoxDecoration(
                                                    color: isActive ? step['color'] : Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                    boxShadow: isCurrent
                                                        ? [BoxShadow(color: step['color'].withOpacity(0.2), blurRadius: 8, spreadRadius: 1)]
                                                        : [],
                                                    border: Border.all(
                                                      color: isCurrent ? step['color'] : Colors.grey[300]!,
                                                      width: 2, // fixed width for all
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.all(10),
                                                  child: Icon(
                                                    step['icon'],
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                if (index != statusSteps.length - 1)
                                                  Container(
                                                    width: 4,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: connectorActive ? step['color'] : Colors.grey[300],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(width: 16),
                                            // Status details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    step['label'],
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: isActive ? step['color'] : Colors.grey,
                                                      fontSize: isCurrent ? 18 : 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    step['time'],
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    step['description'],
                                                    style: TextStyle(
                                                      color: isActive ? Colors.black87 : Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget buildConnector(int index) {
    // Determine if connector should be active based on current status
    bool isActive = false;
    
    if (order['status'] == 'Accepted') {
      // Show connector between Pending and Accepted
      isActive = index == 0; // Connector after Pending step
    } else if (order['status'] == 'Rejected') {
      // Show connector between Pending and Rejected
      isActive = index == 0; // Connector after Pending step
    }
    
    return SizedBox(
      width: 2,
      height: 40,
      child: Stack(
        children: [
          // Gray background line
          Container(
            width: 2,
            height: 40,
            color: AppColors.border,
          ),
          // Animated blue line
          AnimatedContainer(
            duration: Duration(milliseconds: 800),
            width: 2,
            height: isActive ? 40 : 0, // Animate from 0 to 40
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
} 