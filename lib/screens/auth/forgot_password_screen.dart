import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/helpers.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool _emailSent = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _goBack() {
    if (_emailSent) {
      setState(() => _emailSent = false);
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _sendResetLink({bool isResend = false}) async {
    if (!isResend) {
      if (!_formKey.currentState!.validate()) return;
    }
    final email = emailController.text.trim();
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      Helpers.showSnackBar(context, 'Please enter a valid email address.');
      setState(() => _emailSent = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      if (mounted) {
        setState(() => _emailSent = true);
        Helpers.showSnackBar(
          context,
          'Reset code sent to $email! Please check your inbox or spam folder.',
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        String message = e.message;
        if (message.toLowerCase().contains("rate limit")) {
          message = "Too many requests. Please wait a minute before trying again.";
        } else if (message.toLowerCase().contains("user not found")) {
          message = "No account found with this email address.";
        }
        Helpers.showSnackBar(context, message);
      }
    } catch (e) {
      debugPrint('Supabase reset password request error: $e');
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Network error. Please check your internet and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      Helpers.showSnackBar(context, 'Passwords do not match.');
      return;
    }

    setState(() => isLoading = true);

    try {
      if (otp.isNotEmpty) {
        await Supabase.instance.client.auth.verifyOTP(
          email: email,
          token: otp,
          type: OtpType.recovery,
        );
      }

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Password reset successfully! Please login with your new password.',
        );
        _navigateToLogin();
      }
    } on AuthException catch (e) {
      if (mounted) {
        String message = e.message;
        if (message.toLowerCase().contains("token") ||
            message.toLowerCase().contains("otp") ||
            message.toLowerCase().contains("invalid")) {
          message = "Invalid or expired reset code. Please request a new code.";
        }
        Helpers.showSnackBar(context, message);
      }
    } catch (e) {
      debugPrint('Supabase password reset update error: $e');
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Network error. Please check your internet and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textNavy = isDark ? Colors.white : const Color(0xFF0F2C59);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final textHint = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);
    final backIconColor = isDark ? Colors.white : const Color(0xFF0F2C59);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);
    final inputFill = isDark ? const Color(0xFF111827) : Colors.white;

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Back Button ──
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _goBack,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: backIconColor,
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: screenSize.height * 0.03),

                      // ── Lock Icon Image ──
                      SizedBox(
                        height: 140,
                        width: 140,
                        child: Image.asset(
                          AppImages.forgotPassword,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.mark_email_read_rounded,
                              size: 80,
                              color: Color(0xFF067A46),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Title ──
                      Text(
                        _emailSent ? 'Check Your Email' : 'Forgot Password?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: textNavy,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Subtitle ──
                      Text(
                        _emailSent
                            ? 'A reset code has been sent to ${emailController.text.trim()}. Please check your email and enter the OTP code and your new password below.'
                            : 'Enter your email address and we\'ll send you instructions to reset your password.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: textSecondary,
                          height: 1.55,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.03),

                      if (!_emailSent) ...[
                        // ── Email Label ──
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textNavy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ── Email Field ──
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.outfit(fontSize: 15, color: textPrimary),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: inputFill,
                            hintText: 'Enter your email',
                            hintStyle: GoogleFonts.outfit(color: textHint),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF067A46), width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFC62828)),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFC62828), width: 1.5),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email is required';
                            }
                            final regex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!regex.hasMatch(val.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // ── Send Reset Link Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _sendResetLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF067A46),
                              disabledBackgroundColor:
                                  const Color(0xFF067A46).withValues(alpha: 0.6),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Send Reset Link',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ] else ...[
                        // ── Reset Code / OTP Field ──
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'OTP Code / Reset Token',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textNavy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.outfit(fontSize: 15, color: textPrimary),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: inputFill,
                            hintText: 'Enter 6-digit code from email',
                            hintStyle: GoogleFonts.outfit(color: textHint),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF067A46), width: 1.5),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter reset code from your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── New Password Field ──
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'New Password',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textNavy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: _obscureNewPassword,
                          style: GoogleFonts.outfit(fontSize: 15, color: textPrimary),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: inputFill,
                            hintText: 'Enter new password',
                            hintStyle: GoogleFonts.outfit(color: textHint),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF067A46), width: 1.5),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: textHint,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscureNewPassword = !_obscureNewPassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Confirm Password Field ──
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Confirm New Password',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textNavy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: GoogleFonts.outfit(fontSize: 15, color: textPrimary),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: inputFill,
                            hintText: 'Re-enter new password',
                            hintStyle: GoogleFonts.outfit(color: textHint),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF067A46), width: 1.5),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: textHint,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (val) {
                            if (val != newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // ── Reset Password Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF067A46),
                              disabledBackgroundColor:
                                  const Color(0xFF067A46).withValues(alpha: 0.6),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Reset Password',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Options Row (Resend Code / Change Email) ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: isLoading ? null : () => _sendResetLink(isResend: true),
                              icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF067A46)),
                              label: Text(
                                'Resend Code',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF067A46),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => setState(() => _emailSent = false),
                              icon: Icon(Icons.edit_outlined, size: 16, color: textSecondary),
                              label: Text(
                                'Change Email',
                                style: GoogleFonts.outfit(
                                  color: textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ── Footer ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Remember your password? ',
                            style: GoogleFonts.outfit(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: _goBack,
                            child: Text(
                              'Login',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF067A46),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
