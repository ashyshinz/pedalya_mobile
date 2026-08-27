import 'package:flutter/material.dart';

import 'package:pedalya_mobile/core/theme/app_colors.dart';
import 'package:pedalya_mobile/widgets/onboarding/welcome_widgets.dart';


// ============================================================
// PAGE 4 — READY TO RIDE?
// ============================================================

class WelcomeReadyPage extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onLogin;
  final VoidCallback onBack;

  const WelcomeReadyPage({
    super.key,
    required this.onStart,
    required this.onLogin,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final bool narrowScreen = width < 380;
        final bool shortScreen = height < 720;

        final double horizontalPadding =
            narrowScreen ? 20.0 : 28.0;

        final double titleSize =
            (width * 0.115).clamp(40.0, 47.0).toDouble();

        final double iconSize =
            (width * 0.215).clamp(72.0, 88.0).toDouble();

        return Container(
          color: const Color(0xFF191B2B),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                shortScreen ? 14 : 26,
                horizontalPadding,
                shortScreen ? 16 : 26,
              ),
              child: Column(
                children: [
                  // ==========================================
                  // BACK BUTTON
                  // ==========================================
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: onBack,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ==========================================
                  // BIKE ICON
                  // ==========================================
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          primary,
                          secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        iconSize * 0.32,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(
                            alpha: 0.20,
                          ),
                          blurRadius: 32,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.pedal_bike_rounded,
                      color: ink,
                      size: iconSize * 0.51,
                    ),
                  ),

                  SizedBox(
                    height: shortScreen ? 18 : 24,
                  ),

                  // ==========================================
                  // BRAND
                  // ==========================================
                  const Text(
                    'PEDALYA • DAVAO CITY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primary,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(
                    height: shortScreen ? 20 : 27,
                  ),

                  // ==========================================
                  // TITLE
                  // ==========================================
                  Text(
                    'READY TO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      height: 0.95,
                      letterSpacing: -1.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  Text(
                    'RIDE?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primary,
                      fontSize: titleSize,
                      height: 0.95,
                      letterSpacing: -1.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(
                    height: shortScreen ? 16 : 24,
                  ),

                  // ==========================================
                  // DESCRIPTION
                  // ==========================================
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Text(
                      'Explore Davao one pedal at a time '
                      'with Pedalya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFB9BAC8),
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ==========================================
                  // DOTS
                  // ==========================================
                  const WelcomeDots(
                    activeIndex: 3,
                  ),

                  SizedBox(
                    height: shortScreen ? 20 : 28,
                  ),

                  // ==========================================
                  // START PEDALING BUTTON
                  // Responsive full width
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    child: WelcomePrimaryButton(
                      label: 'Start Pedaling',
                      onTap: onStart,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==========================================
                  // LOGIN
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onLogin,
                      child: const Text(
                        'I already have an account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFB6B7C1),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: shortScreen ? 0 : 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
