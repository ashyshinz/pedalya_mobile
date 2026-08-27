import 'package:flutter/material.dart';
import 'package:pedalya_mobile/widgets/onboarding/welcome_widgets.dart';

// ============================================================
// PAGE 2 — YOUR RIDE. YOUR TIME.
// ============================================================

class WelcomeRentalPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const WelcomeRentalPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191B2D),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final bool narrowScreen = width < 380;
          final bool shortScreen = height < 720;

          final double horizontalPadding =
              narrowScreen ? 20.0 : 28.0;

          final double imageHeight =
              height * (shortScreen ? 0.43 : 0.46);

          final double panelTop =
              height * (shortScreen ? 0.39 : 0.42);

          final double titleSize =
              (width * 0.12).clamp(40.0, 50.0).toDouble();

          final double topBreathingRoom =
              shortScreen ? 34.0 : height * 0.095;

          return Stack(
            children: [
              // ==============================================
              // TOP PHOTO
              // ==============================================
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: imageHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/image3.jpg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),

                    // Bottom fade only
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Color(0x55191B2D),
                            Color(0xFF191B2D),
                          ],
                          stops: [
                            0.0,
                            0.60,
                            0.82,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==============================================
              // CONTENT PANEL
              // ==============================================
              Positioned(
                top: panelTop,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF191B2D),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(38),
                      topRight: Radius.circular(38),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        shortScreen ? 18 : 26,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: topBreathingRoom,
                          ),

                          // ==================================
                          // BADGE
                          // ==================================
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF242B42),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'EASY RENTAL',
                              style: TextStyle(
                                color: Color(0xFF80D6D4),
                                fontSize: 9,
                                letterSpacing: 1.7,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: shortScreen ? 20 : 29,
                          ),

                          // ==================================
                          // TITLE
                          // ==================================
                          Text(
                            'YOUR RIDE.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleSize,
                              height: 0.90,
                              letterSpacing: -2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'YOUR TIME.',
                            style: TextStyle(
                              color: const Color(0xFFAAD9BB),
                              fontSize: titleSize,
                              height: 0.90,
                              letterSpacing: -2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          SizedBox(
                            height: shortScreen ? 17 : 24,
                          ),

                          // ==================================
                          // DESCRIPTION
                          // ==================================
                          const Text(
                            'Reserve and rent a bike directly '
                            'through Pedalya — no queue, no hassle. '
                            'Tap and ride.',
                            style: TextStyle(
                              color: Color(0xFFC2C3CF),
                              fontSize: 13,
                              height: 1.65,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(
                            height: shortScreen ? 22 : 34,
                          ),

                          // ==================================
                          // DOTS
                          // ==================================
                          const WelcomeDots(
                            activeIndex: 1,
                          ),

                          SizedBox(
                            height: shortScreen ? 20 : 29,
                          ),

                          // ==================================
                          // RESPONSIVE BACK + NEXT BUTTONS
                          //
                          // No fixed 120 width anymore.
                          // Both adapt automatically.
                          // ==================================
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: double.infinity,
                                  child:
                                      WelcomeSecondaryButton(
                                    label: '← Back',
                                    onTap: onBack,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}