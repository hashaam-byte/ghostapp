import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';
import 'welcome_screen.dart';
import '../home/home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final token = await StorageService.getToken();
      
      if (token != null) {
        // Verify token with server
        final response = await ApiClient.get(ApiConfig.me);
        
        if (response.statusCode == 200) {
          final userData = response.data['user'];
          await StorageService.saveUser(userData);
          
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Auth check failed: $e');
    }

    setState(() {
      _isAuthenticated = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const HomeScreen();
    }

    return const WelcomeScreen();
  }
}