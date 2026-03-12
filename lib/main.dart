import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import your screen
import 'screens/register_screen.dart'; // Import another screen
import 'screens/home_screen.dart'; // Import home screen
import 'screens/order_confirmation_screen.dart'; // Import order confirmation screen
import 'screens/profile_edit_screen.dart'; // Import profile edit screen
import 'screens/order_history_screen.dart'; // Import order history screen
import 'screens/order_status_screen.dart'; // Import order history screen
import 'screens/admin_panel_screen.dart'; // Import admin panel screen
import 'screens/admin_welcome_screen.dart'; // Import admin welcome screen
import 'screens/order_details_screen.dart'; // Import order details screen
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Lock to portrait only
    // DeviceOrientation.portraitDown, // (optional) allow upside-down
  ]);
  await ApiService.loadAccessToken();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Booking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Set the home to SplashScreen instead of LoginScreen
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        // OrderConfirmationScreen now requires orderId parameter, so no route needed
        '/profile_edit': (context) => ProfileEditScreen(),
        '/order_history': (context) => const OrderHistoryScreen(),
        // '/order_status': (context) => OrderStatusScreen(),
        '/admin_panel': (context) => const AdminPanelScreen(),
        '/admin_welcome': (context) => const AdminWelcomeScreen(),
        '/order_details': (context) => const OrderDetailsScreen(order: {}, employeeName: '', employeeCode: ''),
      },
    );
  }
}
