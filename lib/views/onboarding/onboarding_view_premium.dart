import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_button.dart';

class OnboardingViewPremium extends StatefulWidget {
  const OnboardingViewPremium({super.key});

  @override
  State<OnboardingViewPremium> createState() => _OnboardingViewPremiumState();
}

class _OnboardingViewPremiumState extends State<OnboardingViewPremium> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.search_rounded,
      title: 'Discover Vehicles',
      description: 'Browse through thousands of cars and bikes. Find your perfect match with advanced filters.',
      color: AppTheme.primary,
    ),
    OnboardingPage(
      icon: Icons.add_circle_rounded,
      title: 'Sell Easily',
      description: 'List your vehicle in minutes. Upload photos, set your price, and connect with buyers.',
      color: AppTheme.accent,
    ),
    OnboardingPage(
      icon: Icons.favorite_rounded,
      title: 'Save Favorites',
      description: 'Keep track of vehicles you love. Get notified when prices change or new listings appear.',
      color: AppTheme.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.subtleGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Get.offAllNamed('/login'),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
              
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], index);
                  },
                ),
              ),
              
              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildIndicator(index == _currentPage),
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms),
              
              const SizedBox(height: 32),
              
              // Next Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
                child: AnimatedButton(
                  text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  icon: _currentPage == _pages.length - 1
                      ? Icons.arrow_forward_rounded
                      : Icons.arrow_forward_rounded,
                  onPressed: _nextPage,
                  width: double.infinity,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.3, end: 0, duration: 400.ms),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: page.color,
            ),
          )
              .animate()
              .scale(delay: 100.ms, duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 400.ms),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0, duration: 600.ms),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

