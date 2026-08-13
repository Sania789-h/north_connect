import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/helpers.dart';
import '../../services/auth_service.dart';
import '../main_navigation_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> signupUser() async {
    if (!_formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      /*
       * Sign up user.
       *
       * IMPORTANT:
       * Name is sent as user metadata.
       * Supabase trigger will automatically
       * create the profile row.
       */
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
      );

      final user = response.user;
      final session = response.session;

      if (user == null) {
        throw Exception("Account could not be created.");
      }

      if (!mounted) return;

      // Email confirmation is enabled
      if (session == null) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            final isDark =
                Theme.of(ctx).brightness == Brightness.dark;

            final titleColor = isDark
                ? Colors.white
                : const Color(0xFF1E293B);

            final contentColor = isDark
                ? const Color(0xFFCBD5E1)
                : const Color(0xFF64748B);

            final bgColor = isDark
                ? const Color(0xFF1E293B)
                : Colors.white;

            return AlertDialog(
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.mark_email_read_rounded,
                    color: Color(0xFF067A46),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Verify Your Email",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                "A verification link has been sent to your email. "
                    "Please verify your email before logging in.",
                style: GoogleFonts.outfit(
                  height: 1.5,
                  fontSize: 14,
                  color: contentColor,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK, Go to Login",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF067A46),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );

        return;
      }

      // If session exists, user is logged in
      Helpers.showSnackBar(
        context,
        "Account Created Successfully",
      );

      Helpers.pushReplacement(
        context,
        const MainNavigationScreen(),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      String message = e.message;

      if (message.toLowerCase().contains("already registered") ||
          message.toLowerCase().contains("user already exists")) {
        message =
        "This email is already registered. Please login.";
      } else if (message.toLowerCase().contains("weak password")) {
        message =
        "Password is too weak. Use at least 6 characters.";
      } else if (message.toLowerCase().contains("invalid email")) {
        message = "Please enter a valid email address.";
      }

      Helpers.showSnackBar(context, message);
    } catch (e) {
      if (!mounted) return;

      Helpers.showSnackBar(
        context,
        "Signup Error: $e",
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hint,
    Widget? suffix,
    required Color hintColor,
    required Color borderColor,
    required Color fillColor,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      hintText: hint,
      hintStyle: GoogleFonts.outfit(
        color: hintColor,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF067A46),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      suffixIcon: suffix,
    );
  }

  Widget _fieldLabel(
      String label, {
        required Color color,
      }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? const Color(0xFF0B1120)
        : const Color(0xFFF8FAFC);

    final textPrimary = isDark
        ? Colors.white
        : const Color(0xFF1E293B);

    final textNavy = isDark
        ? Colors.white
        : const Color(0xFF0F2C59);

    final textSecondary = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);

    final textHint = const Color(0xFF94A3B8);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);

    final inputFill = isDark
        ? const Color(0xFF111827)
        : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 65,
                    color: Color(0xFF067A46),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "Create Account",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textNavy,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Join North Connect",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Full Name
                  _fieldLabel(
                    "Full Name",
                    color: textNavy,
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: textPrimary,
                    ),
                    decoration: _fieldDecoration(
                      hint: "Enter your full name",
                      hintColor: textHint,
                      borderColor: borderColor,
                      fillColor: inputFill,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Full Name is required";
                      }

                      if (value.trim().length < 3) {
                        return "Name must be at least 3 characters";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Email
                  _fieldLabel(
                    "Email",
                    color: textNavy,
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: emailController,
                    keyboardType:
                    TextInputType.emailAddress,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: textPrimary,
                    ),
                    decoration: _fieldDecoration(
                      hint: "Enter your email",
                      hintColor: textHint,
                      borderColor: borderColor,
                      fillColor: inputFill,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Email is required";
                      }

                      final regex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );

                      if (!regex.hasMatch(
                        value.trim(),
                      )) {
                        return "Enter a valid email";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Password
                  _fieldLabel(
                    "Password",
                    color: textNavy,
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: textPrimary,
                    ),
                    decoration: _fieldDecoration(
                      hint: "Create password",
                      hintColor: textHint,
                      borderColor: borderColor,
                      fillColor: inputFill,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                            !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: textHint,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Password is required";
                      }

                      if (value.trim().length < 6) {
                        return "Minimum 6 characters";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Confirm Password
                  _fieldLabel(
                    "Confirm Password",
                    color: textNavy,
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                    confirmPasswordController,
                    obscureText: _obscureConfirm,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: textPrimary,
                    ),
                    decoration: _fieldDecoration(
                      hint: "Confirm password",
                      hintColor: textHint,
                      borderColor: borderColor,
                      fillColor: inputFill,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirm =
                            !_obscureConfirm;
                          });
                        },
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: textHint,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Confirm your password";
                      }

                      if (value.trim() !=
                          passwordController.text.trim()) {
                        return "Passwords do not match";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                      isLoading ? null : signupUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF067A46),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child:
                        CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        "Sign Up",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.outfit(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Login",
                          style: GoogleFonts.outfit(
                            color:
                            const Color(0xFF067A46),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}