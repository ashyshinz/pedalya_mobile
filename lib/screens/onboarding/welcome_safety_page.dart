import 'package:flutter/material.dart';

import 'package:pedalya_mobile/core/theme/app_colors.dart';
import 'package:pedalya_mobile/widgets/onboarding/welcome_widgets.dart';

// ============================================================
// PAGE 3 — RIDE WITH CONFIDENCE
// ============================================================

class WelcomeSafetyPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const WelcomeSafetyPage({
    super.key,
    required this.onNext,
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
            (width * 0.105).clamp(36.0, 43.0).toDouble();

        return Container(
          color: const Color(0xFF102125),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                shortScreen ? 18 : 32,
                horizontalPadding,
                shortScreen ? 18 : 26,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // SCROLLABLE CONTENT AREA
                  //
                  // On normal phones it looks the same.
                  // On a short phone it can vertically scroll
                  // instead of causing overflow.
                  // ==========================================
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ==================================
                          // BADGE
                          // ==================================
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF173136),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'RIDE SMART',
                              style: TextStyle(
                                color: primary,
                                fontSize: 9,
                                letterSpacing: 1.5,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: shortScreen ? 20 : 28,
                          ),

                          // ==================================
                          // TITLE
                          // ==================================
                          Text(
                            'RIDE WITH',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleSize,
                              height: 0.95,
                              letterSpacing: -1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          Text(
                            'CONFIDENCE.',
                            style: TextStyle(
                              color: accent,
                              fontSize: titleSize,
                              height: 0.95,
                              letterSpacing: -1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          SizedBox(
                            height: shortScreen ? 15 : 22,
                          ),

                          // ==================================
                          // DESCRIPTION
                          // ==================================
                          const Text(
                            'Stay safe and informed with live '
                            'tracking, zone alerts, and real-time '
                            'ride data.',
                            style: TextStyle(
                              color: Color(0xFFC4CBD5),
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),

                          SizedBox(
                            height: shortScreen ? 20 : 28,
                          ),

                          // ==================================
                          // FEATURES
                          // ==================================
                          const WelcomeSafetyFeature(
                            icon: Icons.location_on_rounded,
                            title: 'Live GPS Tracking',
                            glowColor: primary,
                          ),

                          const SizedBox(height: 12),

                          const WelcomeSafetyFeature(
                            icon: Icons.timer_outlined,
                            title: 'Rental Timer',
                            glowColor: secondary,
                          ),

                          const SizedBox(height: 12),

                          const WelcomeSafetyFeature(
                            icon: Icons.map_outlined,
                            title: 'Zone Monitoring',
                            glowColor: accent,
                          ),

                          const SizedBox(height: 12),

                          const WelcomeSafetyFeature(
                            icon: Icons.shield_outlined,
                            title: 'Safety Alerts',
                            glowColor: Color(0xFFF9F7C9),
                          ),

                          SizedBox(
                            height: shortScreen ? 18 : 24,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==========================================
                  // DOTS
                  // ==========================================
                  const WelcomeDots(
                    activeIndex: 2,
                  ),

                  SizedBox(
                    height: shortScreen ? 16 : 23,
                  ),

                  // ==========================================
                  // RESPONSIVE BACK + NEXT
                  // ==========================================
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: double.infinity,
                          child: WelcomeSecondaryButton(
                            label: '← Back',
                            onTap: onBack,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          width: double.infinity,
                          child: WelcomePrimaryButton(
                            label: 'Next',
                            onTap: onNext,
                          ),
                        ),
                      ),
                    ],
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