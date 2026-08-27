import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/onboarding/welcome_widgets.dart';

class WelcomeIntroPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onLogin;

  const WelcomeIntroPage({
    super.key,
    required this.onNext,
    required this.onLogin,
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

        final double topPadding =
            shortScreen ? 18.0 : 28.0;

        final double bottomPadding =
            shortScreen ? 18.0 : 26.0;

        final double heroFontSize =
            (width * 0.13).clamp(42.0, 54.0).toDouble();

        return Stack(
          fit: StackFit.expand,
          children: [
            // ==================================================
            // BACKGROUND IMAGE
            // ==================================================
            Image.asset(
              'assets/images/image6.jpg',
              fit: BoxFit.cover,
            ),

            // ==================================================
            // DARK IMAGE OVERLAY
            // ==================================================
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x55000000),
                    Color(0xAA0B0D15),
                    Color(0xFF10121D),
                  ],
                  stops: [
                    0.0,
                    0.48,
                    0.82,
                  ],
                ),
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // LOCATION BADGE
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pedal_bike_rounded,
                            size: 13,
                            color: ink,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'DAVAO CITY • PEDALYA',
                            style: TextStyle(
                              color: ink,
                              fontSize: 9,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ==========================================
                    // BIG HERO TEXT
                    // ==========================================
                    Text(
                      'PEDAL.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: heroFontSize,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                      ),
                    ),

                    Text(
                      'EXPLORE.',
                      style: TextStyle(
                        color: primary,
                        fontSize: heroFontSize,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                      ),
                    ),

                    Text(
                      'REPEAT.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: heroFontSize,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                      ),
                    ),

                    SizedBox(
                      height: shortScreen ? 14 : 22,
                    ),

                    // ==========================================
                    // DESCRIPTION
                    // ==========================================
                    ConstrainedBox(
  constraints: const BoxConstraints(
    maxWidth: 310,
  ),
                      child: Text(
                        'Discover bikes and start your next ride '
                        'in seconds. Davao is waiting.',
                        style: TextStyle(
                          color: Color(0xFFCACCD6),
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: shortScreen ? 14 : 22,
                    ),

                    // ==========================================
                    // DOTS
                    // ==========================================
                    const WelcomeDots(
                      activeIndex: 0,
                    ),

                    SizedBox(
                      height: shortScreen ? 18 : 26,
                    ),

                    // ==========================================
                    // LET'S GO BUTTON
                    // Full available width
                    // ==========================================
                    SizedBox(
                      width: double.infinity,
                      child: WelcomePrimaryButton(
                        label: "Let's Go",
                        onTap: onNext,
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
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
