import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';
import '../auth/login_screen.dart';

class OnboardingItem {
  final String image;
  final String title;
  final String description;

  const OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      image: AppImages.onboarding1,
      title: 'Stay Connected',
      description:
          'Get real-time network updates from all major carriers in Gilgit-Baltistan.',
    ),
    OnboardingItem(
      image: AppImages.onboarding2,
      title: 'Get Alerts Instantly',
      description:
          'Receive important alerts about weather, road blocks, disasters and emergencies.',
    ),
    OnboardingItem(
      image: AppImages.onboarding3,
      title: 'Emergency SOS',
      description:
          'Send SOS and share your location with emergency contacts instantly.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final mintCircle = isDark ? const Color(0xFF112E20) : const Color(0xFFE0F5E6);
    final indicatorInactive = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
    final isLastPage = _currentIndex == _items.length - 1;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _navigateToLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: textSecondary,
                    textStyle: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      final availableHeight = constraints.maxHeight;
                      final maxCircleByWidth = availableWidth;
                      final maxCircleByHeight = availableHeight * 0.52;
                      final safeCircleSize = maxCircleByWidth < maxCircleByHeight
                          ? maxCircleByWidth
                          : maxCircleByHeight;
                      final spacing = (availableHeight * 0.04).clamp(12.0, 28.0);
                      final titleSize = (availableHeight * 0.062).clamp(20.0, 26.0);
                      final descSize = (availableHeight * 0.036).clamp(13.0, 15.0);
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: SizedBox(
                          height: availableHeight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: safeCircleSize,
                                height: safeCircleSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: mintCircle,
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      item.image,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.image_outlined,
                                          size: 80,
                                          color: Color(0xFF067A46),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: spacing),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  item.description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: descSize,
                                    fontWeight: FontWeight.w400,
                                    color: textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 32.0,
                right: 32.0,
                bottom: 32.0,
                top: 8.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_items.length, (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        width: isActive ? 20.0 : 7.0,
                        height: 7.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: isActive
                              ? const Color(0xFF067A46)
                              : indicatorInactive,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF067A46),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!isLastPage) ...[
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
