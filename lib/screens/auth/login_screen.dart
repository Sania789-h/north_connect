import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/helpers.dart';
import '../../services/auth_service.dart';
import '../main_navigation_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _GoogleIconPainter(),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.24;

    final rect = Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8);
    
    // Red: Top-left to top-right
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.5, 1.8, false, paint);
    
    // Yellow: Left bottom
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -3.9, 1.4, false, paint);
    
    // Green: Bottom
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.9, 1.6, false, paint);

    // Blue: Right & Horizontal bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.7, 1.6, false, paint);
    
    // Draw the horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(w * 0.5, h * 0.42, w * 0.42, h * 0.16),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Skip Button
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
                        foregroundColor: const Color(0xFF475569),
                        textStyle: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Skip'),
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
                  
                  // App Title (GB CONNECT)
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
                          text: 'GB ',
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
                      color: const Color(0xFF475569),
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
                        color: const Color(0xFF0F2C59),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.outfit(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
                        color: const Color(0xFF0F2C59),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    style: GoogleFonts.outfit(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
                  
                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF067A46),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                  const SizedBox(height: 24),
                  
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'or continue with',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Social Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Helpers.showSnackBar(context, "Google login coming soon!");
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const GoogleIcon(),
                              const SizedBox(width: 8),
                              Text(
                                'Google',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Helpers.showSnackBar(context, "Apple login coming soon!");
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.apple,
                                color: Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Apple',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Footer Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
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