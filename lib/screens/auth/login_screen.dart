import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/helpers.dart';
import '../../services/auth_service.dart';
import '../main_navigation_screen.dart';
import 'signup_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();
  bool isLoading = false;
  bool _obscureText = true;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      final response = await authService.signIn(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        try {
          await Supabase.instance.client.from('profiles').upsert({
            'id': user.id,
            'email': email,
          });
        } catch (dbError) {
          debugPrint("Profile upsert bypassed on login: $dbError");
        }
      }

      if (mounted) {
        Helpers.pushReplacement(
          context,
          const MainNavigationScreen(),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        String message = e.message;
        if (message.toLowerCase().contains("invalid login credentials")) {
          message = "Incorrect email or password. Please try again.";
        } else if (message.toLowerCase().contains("email not confirmed")) {
          message = "Your email has not been verified. Please check your inbox.";
        }
        Helpers.showSnackBar(context, message);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, "Connection Error: Please check your internet connection.");
      }
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textNavy = isDark ? Colors.white : const Color(0xFF0F2C59);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final textSkip = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);
    final inputFill = isDark ? const Color(0xFF111827) : Colors.white;

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Skip Now Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Helpers.pushReplacement(
                          context,
                          const MainNavigationScreen(),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: textSkip,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Skip Now',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textSkip,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: textSkip,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Logo Emblem
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: screenSize.height * 0.14,
                    ),
                    child: Image.asset(
                      AppImages.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.landscape_rounded,
                          size: 72,
                          color: Color(0xFF067A46),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // App Title (NORTH CONNECT)
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      children: const [
                        TextSpan(
                          text: 'NORTH ',
                          style: TextStyle(
                            color: Color(0xFF0F2C59), // Deep Navy Blue
                          ),
                        ),
                        TextSpan(
                          text: 'CONNECT',
                          style: TextStyle(
                            color: Color(0xFF067A46), // Vibrant Green
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Welcome Text
                  Text(
                    'Welcome Back!',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textSkip,
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  // Email Input Field
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
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.outfit(fontSize: 15, color: textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputFill,
                      hintText: 'Enter your email',
                      hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        borderSide: const BorderSide(color: Color(0xFF067A46), width: 1.5),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Email is required";
                      }
                      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!regex.hasMatch(val.trim())) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Password Input Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    style: GoogleFonts.outfit(fontSize: 15, color: textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputFill,
                      hintText: 'Enter your password',
                      hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        borderSide: const BorderSide(color: Color(0xFF067A46), width: 1.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 22,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Password is required";
                      }
                      if (val.trim().length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 36),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF067A46),
                        foregroundColor: Colors.white,
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
                              'Login',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Footer Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.outfit(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF067A46),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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