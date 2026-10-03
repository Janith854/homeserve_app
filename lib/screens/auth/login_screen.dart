import 'package:homeserve_app/services/auth_service.dart';
// Screen 1 â€” Login / Sign Up
// Implements: FR01 â€” User Authentication (Member 1)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 1: Login / Sign Up â€” FR01
class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onNavigateToSignUp;
  final VoidCallback? onForgotPassword;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onNavigateToSignUp,
    this.onForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedTabIndex = 0; // 0: Login, 1: Sign Up

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService.instance;
      await authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        widget.onLoginSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Enter your email above to receive a password reset link.';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage = 'Password reset email sent. Check your inbox.';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getFriendlyErrorMessage(e.code, e.message);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to send password reset email.';
        });
      }
    }
  }

  String _getFriendlyErrorMessage(String code, String? defaultMessage) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet.';
      default:
        return defaultMessage ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl + 2, // 14px
            vertical: AppSpacing.xxl + 2, // 14px
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  28,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),

                  // Brand Logo & Subtitle
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.home_repair_service_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Text(
                              'HomeServe',
                              style: AppTextStyles.h1.copyWith(fontSize: 22),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Trusted help, right at home',
                          style: AppTextStyles.meta,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4l),

                  // Segmented Tabs: Login / Sign Up
                  TabSelector(
                    tabs: const ['Login', 'Sign Up'],
                    selectedIndex: _selectedTabIndex,
                    onTap: (index) {
                      if (index == 1) {
                        widget.onNavigateToSignUp?.call();
                      } else {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Inline Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningBannerBg,
                        border: Border.all(color: AppColors.danger),
                        borderRadius: BorderRadius.circular(AppRadius.btn),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 16,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.warnBanner.copyWith(
                                color: AppColors.danger,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Inline Success Banner
                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(AppRadius.btn),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: AppTextStyles.warnBanner.copyWith(
                                color: AppColors.primaryDark,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.fieldFilled,
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      hintStyle: AppTextStyles.field,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                        vertical: 11,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.btn),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.btn),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTextStyles.fieldFilled,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: AppTextStyles.field,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                        vertical: 11,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.muted,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.btn),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.btn),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _handleForgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.link,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Login Primary Button
                  PrimaryButton(
                    label: 'Login',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Divider OR
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.border, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Text(
                          'OR',
                          style: AppTextStyles.meta.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.border, thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Continue with Google Outline Button
                  OutlineAppButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata_rounded,
                    onPressed: () {
                      // TODO: Google Sign-in flow
                    },
                  ),

                  const Spacer(),
                  const SizedBox(height: AppSpacing.x4l),

                  // Bottom Sign Up Switch Link
                  Center(
                    child: GestureDetector(
                      onTap: widget.onNavigateToSignUp ?? () {
                        // Navigate to Screen 1b
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: AppTextStyles.meta.copyWith(fontSize: 12),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: AppTextStyles.link,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


