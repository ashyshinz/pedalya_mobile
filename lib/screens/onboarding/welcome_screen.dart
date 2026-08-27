import 'package:flutter/material.dart';

import 'welcome_intro_page.dart';
import 'welcome_rental_page.dart';
import 'welcome_safety_page.dart';
import 'welcome_ready_page.dart';

class Welcome extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const Welcome({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  void _nextPage() {
    if (currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10121D),
      body: PageView(
        controller: _pageController,

        // User cannot manually swipe between onboarding pages.
        physics: const NeverScrollableScrollPhysics(),

        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },

        children: [
          WelcomeIntroPage(
            onNext: _nextPage,
            onLogin: widget.onLogin,
          ),

          WelcomeRentalPage(
            onNext: _nextPage,
            onBack: _previousPage,
          ),

          WelcomeSafetyPage(
            onNext: _nextPage,
            onBack: _previousPage,
          ),

          WelcomeReadyPage(
            onStart: widget.onRegister,
            onLogin: widget.onLogin,
            onBack: _previousPage,
          ),
        ],
      ),
    );
  }
}