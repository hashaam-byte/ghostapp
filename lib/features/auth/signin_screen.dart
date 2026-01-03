import 'package:flutter/material.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/services/api_client.dart';
import '../../core/services/storage_service.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../tutorial/tutorial_screen.dart';
import '../home/home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // CRITICAL: Check if widget is still mounted and controllers exist
    if (!mounted) {
      debugPrint('❌ Widget disposed, cannot sign in');
      return;
    }

    // Validate form
    if (_formKey.currentState?.validate() != true) return;

    // Show loading
    setState(() => _isLoading = true);

    try {
      debugPrint('🔐 Attempting sign in...');
      
      final response = await ApiClient.post(
        ApiConfig.signin,
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Check your internet connection.');
        },
      );

      debugPrint('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final user = data['user'];
        final needsOnboarding = data['needsOnboarding'] ?? false;

        debugPrint('✅ Sign in successful');
        debugPrint('👤 User: ${user['email']}');
        debugPrint('🎯 Needs onboarding: $needsOnboarding');

        // Save token and user data
        await StorageService.saveToken(token);
        await StorageService.saveUser(user);
        await StorageService.setGuestMode(false);

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back! 👻'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate based on onboarding status
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;

        if (needsOnboarding) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const InteractiveTutorialScreen(),
            ),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
            (route) => false,
          );
        }
      } else {
        throw Exception(response.data['message'] ?? 'Sign in failed');
      }
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      
      if (mounted) {
        // Parse error message
        String errorMessage = 'Sign in failed. Please try again.';
        
        if (e.toString().contains('Invalid email or password')) {
          errorMessage = 'Invalid email or password';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Connection timeout. Check your internet.';
        } else if (e.toString().contains('Network')) {
          errorMessage = 'Network error. Check your connection.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                // Just dismiss
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.ghostWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),

                  // Email
                  CustomTextField(
                    label: 'Email or Username',
                    hint: 'your@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.person_outline),
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email or username is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  CustomTextField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    enabled: !_isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : () {
                        // TODO: Implement forgot password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset coming soon!'),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.auraEnd,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign In Button
                  CustomButton(
                    text: 'Sign In',
                    onPressed: _isLoading ? null : _signIn,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ),

                  const SizedBox(height: 16),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.auraStart,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Debug info (remove in production)
                  if (const bool.fromEnvironment('dart.vm.product') == false)
                    Center(
                      child: Text(
                        'API: ${ApiConfig.baseUrl}',
                        style: TextStyle(
                          color: AppTheme.ghostWhite.withOpacity(0.3),
                          fontSize: 10,
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