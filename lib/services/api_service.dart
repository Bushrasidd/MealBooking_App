import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Replace with your actual backend URL
  static const String baseUrl = 'https://project1.arabiand.me'; // Local FastAPI server
  
  // Login endpoint
  static const String loginEndpoint = '/api/v1/login/access-token';
  
  // Store the access token
  static String? _accessToken;
  
  // Getter for access token
  static String? get accessToken => _accessToken;
  
  static Future<void> setAccessToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = jsonEncode(userData);
    await prefs.setString('user_data', userDataString);
    print('💾 Storing user data: $userDataString');
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    print('🔍 Retrieved user data string: $userDataString');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      print('🔍 Decoded user data: $userData');
      return userData;
    }
    print('❌ No user data found in SharedPreferences');
    return null;
  }

  static Future<void> loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }
  
  // Login method
  static Future<Map<String, dynamic>> login(String empCode, String password) async {
    print('🔐 Attempting login with emp_code: $empCode');
    print('🌐 API URL: $baseUrl$loginEndpoint');
    
    try {
      final requestBody = {
        'username': empCode,  // FastAPI expects 'username' field
        'password': password,
      };
      print('📤 Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'username=$empCode&password=$password',
      );
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      print('📥 Response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Login successful: $data');
        // Store the access token
        if (data['access_token'] != null) {
          await setAccessToken(data['access_token']);
          print('🔑 Access token stored');
        }
        return data;
      } else {
        print('❌ Login failed: ${response.statusCode} - ${response.body}');
        throw Exception('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Network error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // Helper method to get headers with auth token
  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };
  }
  
  static Future<void> logout() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/users/me'),
      headers: getAuthHeaders(), // This should include the Bearer token
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch profile: ${response.body}');
    }
  }

  static Future<void> updateProfile(Map<String, dynamic> updatedProfile) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/v1/users/me'),
      headers: getAuthHeaders(),
      body: jsonEncode(updatedProfile),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  static Future<void> placeOrder({required String orderType, required DateTime date}) async {
    // Format date as "yyyy-MM-dd"
    final dateStr = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    // Format time as "HH:mm"
    final timeStr = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/orders/'),
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'order_type': orderType.toLowerCase(), // "lunch" or "dinner"
        'date': dateStr,
        'time': timeStr,
      }),
    );
    print('Order response: ${response.statusCode} ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to place order: ${response.body}');
    }
  }

  static Future<bool> hasOrderedToday(String orderType) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/orders/me/today'),
      headers: getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Adjust this based on your backend's response structure
      // For example, if the backend returns a list of orders:
      return (data['data'] as List).isNotEmpty;
      // Or if it returns a boolean:
      // return data['has_ordered'] == true;
    } else {
      throw Exception('Failed to check order status: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/orders/me'),
      headers: getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/orders/'),
      headers: getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to fetch all orders: ${response.body}');
    }
  }

  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final url = '$baseUrl/api/v1/orders/$orderId';
    final response = await http.put(
      Uri.parse(url),
      headers: getAuthHeaders(),
      body: jsonEncode({'status': newStatus}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }

  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final url = '$baseUrl/api/v1/orders/$orderId';
    print('🔍 Fetching order: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: getAuthHeaders(),
    );
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('📥 Parsed data: $data');
      // Handle both response formats: {data: {...}} or direct {...}
      final result = data['data'] ?? data;
      print('📥 Final result: $result');
      return result;
    } else {
      throw Exception('Failed to fetch order: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> placeOrderAndReturn({
  required String orderType,
  required DateTime date,
}) async {
  final dateStr = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  final timeStr = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

  final url = '$baseUrl/api/v1/orders/';
  final response = await http.post(
    Uri.parse(url),
    headers: getAuthHeaders(),
    body: jsonEncode({
      'order_type': orderType.toLowerCase(),
      'date': dateStr,
      'time': timeStr,
    }),
  );
  if (response.statusCode == 201 || response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] ?? data;
  } else {
    throw Exception('Failed to place order: ${response.body}');
  }
}
} 