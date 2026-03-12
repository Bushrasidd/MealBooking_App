import 'package:flutter/material.dart';
import 'order_status_screen.dart';
import '../services/api_service.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  
  const OrderConfirmationScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  AnimationController? _iconController;
  AnimationController? _textController;
  Animation<double>? _iconAnimation;
  Animation<double>? _textAnimation;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Icon animation controller
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Text animation controller (starts after icon)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController!,
      curve: Curves.easeOutBack,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController!,
      curve: Curves.easeOut,
    ));

    // Start animations in sequence
    _iconController!.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _textController!.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _iconController?.dispose();
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if animations are initialized
    if (_iconAnimation == null || _textAnimation == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
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
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
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
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.all(32),
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFF8FAFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon with smooth animation
                  AnimatedBuilder(
                    animation: _iconAnimation!,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(100 * (1 - _iconAnimation!.value), 0),
                        child: Transform.scale(
                          scale: _iconAnimation!.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF667eea).withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Order confirmed text with fade-in animation
                  AnimatedBuilder(
                    animation: _textAnimation!,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textAnimation!.value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _textAnimation!.value)),
                          child: Column(
                            children: [
                              const Text(
                                'ORDER CONFIRMED',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Your order has been successfully placed',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF718096),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Done button
                  Container(
                    width: double.infinity,
                    height: 56,
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
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderStatusScreen(order: widget.order),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'DONE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
    );
  }
} 