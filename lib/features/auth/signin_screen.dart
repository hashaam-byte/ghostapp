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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post(
        ApiConfig.signin,
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final user = data['user'];
        final needsOnboarding = data['needsOnboarding'] ?? false;

        // Save token and user data
        await StorageService.saveToken(token);
        await StorageService.saveUser(user);
        await StorageService.setGuestMode(false);

        if (!mounted) return;

        // Navigate based on onboarding status
        if (needsOnboarding) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const TutorialScreen(),
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
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
                      onPressed: () {
                        // TODO: Implement forgot password
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
                    onPressed: _signIn,
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
                        onPressed: () => Navigator.pop(context),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}