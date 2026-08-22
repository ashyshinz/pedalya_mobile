import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

void main() => runApp(const PedalyaApp());

const primary = Color(0xFF80BCBD);
const secondary = Color(0xFFAAD9BB);
const accent = Color(0xFFD5F0C1);
const background = Color(0xFFF9F7C9);
const ink = Color(0xFF214645);
const muted = Color(0xFF66817A);

class PedalyaApp extends StatelessWidget {
  const PedalyaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pedalya',
    theme: ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: primary,
    secondary: secondary,
    surface: Colors.white,
    onPrimary: ink,
  ),

  scaffoldBackgroundColor: const Color(0xFFFFFEF7),

  // GLOBAL TEXT STYLE
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      color: ink,
      fontSize: 30,
      fontWeight: FontWeight.w900,
    ),
    headlineMedium: TextStyle(
      color: ink,
      fontSize: 26,
      fontWeight: FontWeight.w900,
    ),
    titleLarge: TextStyle(
      color: ink,
      fontSize: 20,
      fontWeight: FontWeight.w900,
    ),
    titleMedium: TextStyle(
      color: ink,
      fontSize: 16,
      fontWeight: FontWeight.w800,
    ),
    bodyLarge: TextStyle(
      color: ink,
      fontSize: 15,
    ),
    bodyMedium: TextStyle(
      color: muted,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: muted,
      fontSize: 12,
    ),
  ),

  // INPUTS
  inputDecorationTheme: InputDecorationThemeData(
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(
      color: muted,
      fontSize: 14,
    ),
    prefixIconColor: muted,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFFE2EAE5),
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFFE2EAE5),
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: primary,
        width: 2,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Colors.red,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 2,
      ),
    ),
  ),

  // SNACKBAR
  snackBarTheme: SnackBarThemeData(
    backgroundColor: ink,
    contentTextStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),

  // DIVIDERS
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE5EBE7),
    thickness: 1,
  ),
),
        home: const RiderApp(),
      );
}

class RiderApp extends StatefulWidget {
  const RiderApp({super.key});

  @override
  State<RiderApp> createState() => _RiderAppState();
}

class _RiderAppState extends State<RiderApp> {
  String stage = 'welcome';
  int tab = 0;
  bool extended = false;

  BikeVariantData? selectedBike;
  
  String selectedDuration = '30 minutes';
int selectedEstimatedCost = 0;
String riderName = 'Alex Rider';

DateTime? rentalStartTime;

  void open(String value) => setState(() => stage = value);
  void dashboard([int index = 0]) => setState(() {
        stage = 'dashboard';
        tab = index;
      });

        void openBike(BikeVariantData bike) {
    setState(() {
      selectedBike = bike;
      stage = 'bike';
    });
  }

void startRental() {
  setState(() {
    rentalStartTime ??= DateTime.now();
    stage = 'active';
  });
}
  @override
Widget build(BuildContext context) {
  Widget body;

  if (stage == 'welcome') {
    body = Welcome(
      onRegister: () => open('register'),
      onLogin: () => open('login'),
    );
} else if (stage == 'login') {
  body = LoginPage(
    onBack: () => open('welcome'),
    onRegister: () => open('register'),
    onDone: dashboard,
  );
 } else if (stage == 'register') {
  body = Register(
    onBack: () => open('welcome'),
    onLogin: () => open('login'),
    onDone: dashboard,
  );
  } else if (stage == 'bike') {
    body = BikeDetails(
      bike: selectedBike!,
      onBack: () => dashboard(1),
      onReserve: (duration, cost) {
        setState(() {
          selectedDuration = duration;
          selectedEstimatedCost = cost;
          stage = 'reservation';
        });
      },
    );
  } else if (stage == 'reservation') {
    body = Reservation(
      bike: selectedBike!,
      duration: selectedDuration,
      estimatedCost: selectedEstimatedCost,
      riderName: riderName,
      onBack: () => open('bike'),
      onContinue: (paymentMethod) {
  if (paymentMethod == 'online') {
    open('payment');
  } else {
    startRental();
  }
},
    );
 } else if (stage == 'payment') {
  body = Payment(
    bike: selectedBike!,
    duration: selectedDuration,
    totalAmount: selectedEstimatedCost,
    onBack: () => open('reservation'),
    onDone: startRental,
  );

} else if (stage == 'active') {
  body = ActiveRide(
    bike: selectedBike!,
    duration: selectedDuration,
    baseAmount: selectedEstimatedCost,
    startTime: rentalStartTime!,
    extended: extended,
    onBack: dashboard,
    onExtend: () => setState(() => extended = true),
    onReturn: () => open('return'),
  );
  
 } else if (stage == 'return') {
  body = ReturnBike(
    bike: selectedBike!,
    baseAmount: selectedEstimatedCost,
    startTime: rentalStartTime!,
    extended: extended,
    onBack: () => open('active'),
    onDone: () => dashboard(2),
  );

  } else {
    body = Dashboard(
      tab: tab,
      onTab: (value) => setState(() => tab = value),
      onBike: openBike,
      onActive: () => open('active'),
      onLogout: () => open('welcome'),
    );
  }

  return body;
}
}


class AppPage extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;
  const AppPage({super.key, required this.child, this.onBack});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Stack(
                children: [
                  child,
                  if (onBack != null)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_rounded, color: ink),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 6,
            child: Text(
              'pedal',
              style: TextStyle(
                fontSize: 170,
                fontWeight: FontWeight.w800,
                height: 0.78,
                letterSpacing: -8,
                color: primary.withValues(alpha: 0.96),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 90,
            child: Transform.rotate(
              angle: -0.18,
              child: Container(
                width: 220,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 32,
                      child: Container(
                        width: 135,
                        height: 6,
                        color: const Color(0xFF4B4B4B),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 10,
                      child: Container(
                        width: 118,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: const Color(0xFF4B4B4B), width: 3),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.pedal_bike_rounded, size: 68, color: Color(0xFF2C2C2C)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 25,
                      top: 0,
                      child: SizedBox(
                        width: 110,
                        height: 72,
                        child: const Icon(Icons.bike_scooter_rounded, size: 58, color: Color(0xFF2C2C2C)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Welcome extends StatefulWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;

  const Welcome({
    super.key,
    required this.onRegister,
    required this.onLogin,
  });

  @override
  State<Welcome> createState() => _WelcomeState();
}


class _WelcomeState extends State<Welcome> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  static const int totalPages = 4;

  void _nextPage() {
    if (currentPage < totalPages - 1) {
      _pageController.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onRegister();
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _pageController.animateToPage(
        currentPage - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
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

      // IMPORTANT:
      // The user CANNOT swipe between onboarding pages.
      // Navigation only happens through the buttons.
      physics: const NeverScrollableScrollPhysics(),

      onPageChanged: (index) {
        setState(() {
          currentPage = index;
        });
      },

      children: [
        _WelcomeIntroPage(
          onNext: _nextPage,
          onLogin: widget.onLogin,
        ),

        _WelcomeRentalPage(
          onNext: _nextPage,
          onBack: _previousPage,
        ),

        _WelcomeSafetyPage(
          onNext: _nextPage,
          onBack: _previousPage,
        ),

        _WelcomeReadyPage(
          onStart: widget.onRegister,
          onLogin: widget.onLogin,
          onBack: _previousPage,
        ),
      ],
    ),
  );
}
}

// ============================================================
// PAGE 1 — PEDAL. EXPLORE. REPEAT.
// ============================================================

class _WelcomeIntroPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onLogin;

  const _WelcomeIntroPage({
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
                    const _WelcomeDots(
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
                      child: _WelcomePrimaryButton(
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


// ============================================================
// PAGE 2 — YOUR RIDE. YOUR TIME.
// ============================================================

class _WelcomeRentalPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _WelcomeRentalPage({
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
                          const _WelcomeDots(
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
                                      _WelcomeSecondaryButton(
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
                                  child: _WelcomePrimaryButton(
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


// ============================================================
// PAGE 3 — RIDE WITH CONFIDENCE
// ============================================================

class _WelcomeSafetyPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _WelcomeSafetyPage({
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
                          const _WelcomeSafetyFeature(
                            icon: Icons.location_on_rounded,
                            title: 'Live GPS Tracking',
                            glowColor: primary,
                          ),

                          const SizedBox(height: 12),

                          const _WelcomeSafetyFeature(
                            icon: Icons.timer_outlined,
                            title: 'Rental Timer',
                            glowColor: secondary,
                          ),

                          const SizedBox(height: 12),

                          const _WelcomeSafetyFeature(
                            icon: Icons.map_outlined,
                            title: 'Zone Monitoring',
                            glowColor: accent,
                          ),

                          const SizedBox(height: 12),

                          const _WelcomeSafetyFeature(
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
                  const _WelcomeDots(
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
                          child: _WelcomeSecondaryButton(
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
                          child: _WelcomePrimaryButton(
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


// ============================================================
// PAGE 4 — READY TO RIDE?
// ============================================================

class _WelcomeReadyPage extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onLogin;
  final VoidCallback onBack;

  const _WelcomeReadyPage({
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
                  const _WelcomeDots(
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
                    child: _WelcomePrimaryButton(
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


// ============================================================
// SHARED WELCOME WIDGETS
// ============================================================

class _WelcomeDots extends StatelessWidget {
  final int activeIndex;

  const _WelcomeDots({
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (index) {
          final active = index == activeIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(right: 7),
            width: active ? 30 : 8,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? primary
                  : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}


class _WelcomePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WelcomePrimaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF171827),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}


class _WelcomeSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WelcomeSecondaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withValues(
              alpha: 0.25,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}


class _WelcomeSafetyFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color glowColor;

  const _WelcomeSafetyFeature({
    required this.icon,
    required this.title,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF212637),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.07,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.09,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: glowColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: glowColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(
                    alpha: 0.65,
                  ),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onRegister;
  final VoidCallback onDone;

  const LoginPage({
    super.key,
    required this.onBack,
    required this.onRegister,
    required this.onDone,
  });
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;

  final TextEditingController emailController =
      TextEditingController(text: 'rider@pedalya.com');
  final TextEditingController passwordController =
      TextEditingController(text: 'password');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B16),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/PEDAL.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66070B16),
                    Color(0xB3070B16),
                    Color(0xF5070B16),
                    Color(0xFF050814),
                  ],
                  stops: [0.0, 0.35, 0.68, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Align(
  alignment: Alignment.centerLeft,
  child: InkWell(
    onTap: widget.onBack,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      child: const Icon(
        Icons.arrow_back_rounded,
        color: Colors.white70,
        size: 21,
      ),
    ),
  ),
),



                  const SizedBox(height: 220),

RichText(
  text: const TextSpan(
    children: [
      TextSpan(
        text: 'WELCOME BACK,\n',
        style: TextStyle(
          color: Colors.white,
          fontSize: 41,
          height: 0.93,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
        ),
      ),
      TextSpan(
        text: 'RIDER',
        style: TextStyle(
          color: Color(0xFFAAD9BB),
          fontSize: 41,
          height: 0.93,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
        ),
      ),
      TextSpan(
        text: ' 👋',
        style: TextStyle(
          fontSize: 34,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 14),

const Text(
  'Where are we going today?',
  style: TextStyle(
    color: Color(0xFFC7CAD7),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  ),
),

const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1F37).withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LoginField(
                          label: 'EMAIL',
                          icon: Icons.email_outlined,
                          hintText: 'rider@pedalya.com',
                          controller: emailController,
                        ),

                        const SizedBox(height: 15),

                        _LoginField(
                          label: 'PASSWORD',
                          icon: Icons.lock_outline_rounded,
                          hintText: '••••••••',
                          controller: passwordController,
                          obscureText: obscurePassword,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: const Color(0xFF9CA3B2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xFF9EE2DE),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: widget.onDone,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFAAD9BB),
                              foregroundColor: const Color(0xFF182236),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Sign In →',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

const SizedBox(height: 26),

Center(
  child: Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      const Text(
        'New here? ',
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFFB9BDD0),
          fontWeight: FontWeight.w500,
        ),
      ),
      GestureDetector(
        onTap: widget.onRegister,
        child: const Text(
          'Create an account',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF9EE2DE),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  ),
),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffix;

  const _LoginField({
    required this.label,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFFFC857)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB9BED0),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFF2B2F47),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFF80BCBD),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Register extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLogin;
  final VoidCallback onDone;

  const Register({
    super.key,
    required this.onBack,
    required this.onLogin,
    required this.onDone,
  });

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A15),
      body: Stack(
        children: [
          // =========================================
          // BACKGROUND
          // =========================================

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.45, 0.35, 0.30, 0, -25,
                0.30, 0.45, 0.30, 0, -25,
                0.30, 0.35, 0.45, 0, -25,
                0,    0,    0,    1,   0,
              ]),
              child: Image.asset(
                'assets/images/normal_bike.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x55070A14),
                    Color(0xAA080A15),
                    Color(0xFF080A15),
                  ],
                ),
              ),
            ),
          ),

          // =========================================
          // CONTENT
          // =========================================

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                22,
                18,
                22,
                32,
              ),
              children: [
                // BACK
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: widget.onBack,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white70,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 42),

                // BRAND
                const Text(
                  'PEDALYA',
                  style: TextStyle(
                    color: Color(0xFF80D6D4),
                    fontSize: 10,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                // TITLE
                const Text(
                  'JOIN THE RIDE.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 39,
                    height: 0.95,
                    letterSpacing: -1.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const Text(
                  'LET\'S GET YOU READY.',
                  style: TextStyle(
                    color: Color(0xFFAAD9BB),
                    fontSize: 32,
                    height: 1,
                    letterSpacing: -1.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 13),

                const Text(
                  'Create your Pedalya rider account and start exploring.',
                  style: TextStyle(
                    color: Color(0xFFC4C6D0),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 34),

                // =========================================
                // PERSONAL DETAILS CARD
                // =========================================

                Container(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    22,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1D31),
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.07,
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF80D6D4),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'PERSONAL DETAILS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const _RegisterField(
                        label: 'FULL NAME',
                        icon: Icons.person_outline_rounded,
                        hintText: 'Enter your full name',
                      ),

                      const SizedBox(height: 17),

                      const _RegisterField(
                        label: 'EMAIL',
                        icon: Icons.mail_outline_rounded,
                        hintText: 'rider@email.com',
                        keyboardType:
                            TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 17),

                      const _RegisterField(
                        label: 'MOBILE NUMBER',
                        icon: Icons.phone_outlined,
                        hintText: '09XX XXX XXXX',
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 17),

                      _RegisterField(
                        label: 'PASSWORD',
                        icon: Icons.lock_outline_rounded,
                        hintText: 'Create a password',
                        obscureText: obscurePassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: const Color(0xFF9699AA),
                          ),
                        ),
                      ),

                      const SizedBox(height: 17),

                      _RegisterField(
                        label: 'CONFIRM PASSWORD',
                        icon: Icons.lock_outline_rounded,
                        hintText: 'Re-enter your password',
                        obscureText:
                            obscureConfirmPassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword =
                                  !obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: const Color(0xFF9699AA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =========================================
                // ID VERIFICATION CARD
                // =========================================

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1D31),
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.07,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF292D43),
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              color: Color(0xFFAAD9BB),
                            ),
                          ),

                          const SizedBox(width: 11),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Identity verification',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Valid government-issued ID',
                                  style: TextStyle(
                                    color:
                                        Color(0xFF9EA0AF),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF31364A),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'REQUIRED',
                              style: TextStyle(
                                color: Color(0xFFF9F7C9),
                                fontSize: 8,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 17),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25283B),
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.07,
                            ),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons
                                  .add_photo_alternate_outlined,
                              color: Color(0xFF80BCBD),
                              size: 34,
                            ),

                            SizedBox(height: 9),

                            Text(
                              'Upload your valid ID',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'Make sure your name and photo are clearly visible.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    Color(0xFF9EA0AF),
                                fontSize: 10,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 13),

                      Row(
                        children: [
                          Expanded(
                            child: _RegisterUploadButton(
                              icon: Icons
                                  .photo_library_outlined,
                              label: 'Gallery',
                              onTap: () {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Gallery upload will be connected later.',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 9),

                          Expanded(
                            child: _RegisterUploadButton(
                              icon:
                                  Icons.camera_alt_outlined,
                              label: 'Camera',
                              onTap: () {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Camera capture will be connected later.',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // INFO MESSAGE
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13262A),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: const Color(0xFF80BCBD)
                          .withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF80D6D4),
                        size: 20,
                      ),

                      SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          'Your ID must be verified before you can start renting a bicycle.',
                          style: TextStyle(
                            color: Color(0xFFC7CAD2),
                            fontSize: 11,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =========================================
                // CREATE ACCOUNT BUTTON
                // =========================================

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: widget.onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFAAD9BB),
                      foregroundColor:
                          const Color(0xFF171827),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        SizedBox(width: 8),

                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN LINK
                Center(
                  child: GestureDetector(
                    onTap: widget.onLogin,
                    child: const Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: Color(0xFFB8BAC7),
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'Already have an account? ',
                          ),
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color:
                                  Color(0xFF9EE2DE),
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _RegisterField({
    required this.label,
    required this.icon,
    required this.hintText,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFFC857),
              size: 14,
            ),

            const SizedBox(width: 7),

            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB9BBC9),
                fontSize: 10,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        TextField(
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF8E91A2),
              fontSize: 13,
            ),
            suffixIcon: suffix,

            filled: true,
            fillColor: const Color(0xFF2A2D43),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 17,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: Color(0xFF80BCBD),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterUploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RegisterUploadButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              const Color(0xFF9EE2DE),

          side: BorderSide(
            color: const Color(0xFF80BCBD)
                .withValues(alpha: 0.50),
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  final ValueChanged<BikeVariantData> onBike;
  final VoidCallback onActive;
  final VoidCallback onLogout;
 const Dashboard({
  super.key,
  required this.tab,
  required this.onTab,
  required this.onBike,
  required this.onActive,
  required this.onLogout,
});


  @override
  Widget build(BuildContext context) {
final pages = [
  Home(
    onBike: onBike,
    onActive: onActive,
    onTab: onTab,
  ),
  Bikes(onBike: onBike),
  Rentals(onActive: onActive),
  const Alerts(),
  Profile(onLogout: onLogout),
];

    return Scaffold(
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: pages[tab]))),
bottomNavigationBar: Container(
  color: const Color(0xFF0B0D18),
  padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
  child: SafeArea(
    top: false,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181B2C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: NavigationBar(
          height: 68,
          selectedIndex: tab,
          onDestinationSelected: onTab,

          backgroundColor: const Color(0xFF181B2C),

          indicatorColor: const Color(0xFFAAD9BB),

          elevation: 0,

          labelBehavior:
              NavigationDestinationLabelBehavior.alwaysShow,

          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: Color(0xFF8F93A3),
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: Color(0xFF172323),
                size: 23,
              ),
              label: 'Home',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.pedal_bike_outlined,
                color: Color(0xFF8F93A3),
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.pedal_bike_rounded,
                color: Color(0xFF172323),
                size: 23,
              ),
              label: 'Bikes',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.route_outlined,
                color: Color(0xFF8F93A3),
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.route_rounded,
                color: Color(0xFF172323),
                size: 23,
              ),
              label: 'Rentals',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF8F93A3),
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.notifications_rounded,
                color: Color(0xFF172323),
                size: 23,
              ),
              label: 'Alerts',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF8F93A3),
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: Color(0xFF172323),
                size: 23,
              ),
              label: 'Profile',
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

enum BikeVariant {
  kids,
  doubleBike,
  standard,
}

class BikeVariantData {
  final BikeVariant variant;
  final String name;
  final String id;
  final String range;
  final String price;
  final Color accentColor;
  final Color bodyColor;
   final String imagePath;

  const BikeVariantData({
    required this.variant,
    required this.name,
    required this.id,
    required this.range,
    required this.price,
    required this.accentColor,
    required this.bodyColor,
    required this.imagePath,
  });
}

class BikeIllustration extends StatelessWidget {
  final BikeVariant variant;
  final String imagePath;
  final double size;

  const BikeIllustration({
    super.key,
    required this.variant,
    required this.imagePath,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    final bool isKids = variant == BikeVariant.kids;

    if (isKids) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/kids_bike.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) => Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFBFEFE9),
              child: const Icon(Icons.pedal_bike_rounded, size: 48, color: Color(0xFF2E8F9B)),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) => Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE7F9F5),
            child: const Icon(
              Icons.pedal_bike_rounded,
              size: 48,
              color: Color(0xFF245451),
            ),
          ),
        ),
      ),
    );
  }
}

class BikePainter extends CustomPainter {
  final BikeVariant variant;
  final double wheelRadius;
  final Color bodyColor;
  final Color accentColor;
  final double frameTop;

  BikePainter({
    required this.variant,
    required this.wheelRadius,
    required this.bodyColor,
    required this.accentColor,
    required this.frameTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFF2D2D2D);

    final fillPaint = Paint()..color = bodyColor;
    final darkPaint = Paint()..color = const Color(0xFF1E1E1E);
    final accentStroke = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final leftWheelCenter = Offset(centerX - 36, centerY + 18);
    final rightWheelCenter = Offset(centerX + 42, centerY + 18);

    final leftWheel = Rect.fromCenter(center: leftWheelCenter, width: wheelRadius * 2.2, height: wheelRadius * 2.2);
    final rightWheel = Rect.fromCenter(center: rightWheelCenter, width: wheelRadius * 2.2, height: wheelRadius * 2.2);

    canvas.drawArc(leftWheel, 0, math.pi * 2, false, paint);
    canvas.drawArc(rightWheel, 0, math.pi * 2, false, paint);

    final frameTopY = frameTop;
    final seatX = centerX - 18;
    final seatY = centerY - 26;
    final handleX = centerX + 26;
    final handleY = centerY - 40;

    final framePath = Path()
      ..moveTo(leftWheelCenter.dx - 10, leftWheelCenter.dy - 2)
      ..lineTo(centerX - 10, frameTopY)
      ..lineTo(centerX + 28, frameTopY)
      ..lineTo(rightWheelCenter.dx - 14, rightWheelCenter.dy - 2)
      ..lineTo(centerX + 28, frameTopY)
      ..lineTo(centerX - 4, centerY + 18)
      ..lineTo(centerX - 10, frameTopY)
      ..lineTo(centerX - 10, centerY + 18);

    canvas.drawPath(framePath, paint..style = PaintingStyle.stroke);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX + 10, frameTopY + 18), width: 120, height: 46),
      const Radius.circular(18),
    );
    canvas.drawRRect(bodyRect, fillPaint..style = PaintingStyle.fill);
    canvas.drawRRect(bodyRect, paint..style = PaintingStyle.stroke);

    canvas.drawLine(Offset(seatX, seatY), Offset(centerX - 4, frameTopY), paint);
    canvas.drawLine(Offset(handleX, handleY), Offset(centerX + 28, frameTopY), paint);
    canvas.drawLine(Offset(centerX + 28, frameTopY), Offset(centerX + 48, frameTopY - 16), paint);

    canvas.drawLine(Offset(centerX + 14, frameTopY), Offset(centerX + 54, frameTopY - 10), accentStroke);

    final seat = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(seatX, seatY), width: 22, height: 8),
      const Radius.circular(4),
    );
    canvas.drawRRect(seat, paint..style = PaintingStyle.fill);

    canvas.drawCircle(Offset(leftWheelCenter.dx - 3, leftWheelCenter.dy), 3, darkPaint);
    canvas.drawCircle(Offset(rightWheelCenter.dx + 3, rightWheelCenter.dy), 3, darkPaint);

    if (variant == BikeVariant.doubleBike) {
      final secondSeat = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX + 52, seatY), width: 22, height: 8),
        const Radius.circular(4),
      );
      canvas.drawRRect(secondSeat, paint..style = PaintingStyle.fill);
      canvas.drawLine(Offset(centerX + 38, frameTopY), Offset(centerX + 70, frameTopY - 2), paint);
    }

    if (variant == BikeVariant.kids) {
      canvas.drawRect(Rect.fromCenter(center: Offset(centerX - 56, centerY - 8), width: 18, height: 28), paint..style = PaintingStyle.fill);
    }

    if (variant == BikeVariant.standard) {
      canvas.drawLine(Offset(centerX + 7, centerY - 12), Offset(centerX + 48, centerY - 34), paint);
      canvas.drawLine(Offset(centerX + 48, centerY - 34), Offset(centerX + 66, centerY - 32), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
class Home extends StatelessWidget {
  final ValueChanged<BikeVariantData> onBike;
  final VoidCallback onActive;
  final ValueChanged<int> onTab;

  const Home({
    super.key,
    required this.onBike,
    required this.onActive,
    required this.onTab,
  });

  static const List<BikeVariantData> availableBikes = [
    BikeVariantData(
      variant: BikeVariant.kids,
      name: 'Kids Bike',
      id: 'K-001',
      range: 'Age 4–8',
      price: 'PHP 30 / 30 mins',
      accentColor: Color(0xFFBFEFE9),
      bodyColor: Color(0xFF5EC9D4),
      imagePath: 'assets/images/kids_bike.jpg',
    ),
    BikeVariantData(
      variant: BikeVariant.doubleBike,
      name: 'Double Bike',
      id: 'D-204',
      range: '2 riders',
      price: 'PHP 70 / 30 mins',
      accentColor: Color(0xFFE3F4F1),
      bodyColor: Color(0xFF7BCFCF),
      imagePath: 'assets/images/double_bike.jpg',
    ),
    BikeVariantData(
      variant: BikeVariant.standard,
      name: 'Normal Bike',
      id: 'N-118',
      range: '1 rider',
      price: 'PHP 50 / 30 mins',
      accentColor: Color(0xFFEAF8F4),
      bodyColor: Color(0xFF5FC5C8),
      imagePath: 'assets/images/normal_bike.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0D18),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ==================================================
          // DARK HERO AREA
          // ==================================================

          Stack(
            children: [
              SizedBox(
                height: 355,
                width: double.infinity,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.55, 0.20, 0.20, 0, -20,
                    0.20, 0.55, 0.20, 0, -20,
                    0.20, 0.20, 0.55, 0, -20,
                    0,    0,    0,    1,   0,
                  ]),
                  child: Image.asset(
                    'assets/images/normal_bike.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x55070A14),
                        Color(0x88070A14),
                        Color(0xF20B0D18),
                        Color(0xFF0B0D18),
                      ],
                      stops: [
                        0.0,
                        0.42,
                        0.82,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    20,
                    22,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // TOP BAR
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(
                                alpha: 0.30,
                              ),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'PEDALYA',
                              style: TextStyle(
                                color: Color(0xFF80D6D4),
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),

                          const Spacer(),

                          InkWell(
                            onTap: () => onTab(4),
                            borderRadius:
                                BorderRadius.circular(30),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(
                                  alpha: 0.13,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 55),

                      const Text(
                        'GOOD EVENING 👋',
                        style: TextStyle(
                          color: Color(0xFF80D6D4),
                          fontSize: 10,
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'READY FOR\nYOUR NEXT RIDE?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          height: 0.95,
                          letterSpacing: -1.3,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Find a bike nearby and start exploring Davao.',
                        style: TextStyle(
                          color: Color(0xFFC5C7D1),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: 165,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => onTab(1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFAAD9BB),
                            foregroundColor:
                                const Color(0xFF171827),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(28),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pedal_bike_rounded,
                                size: 18,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Find a Bike',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ==================================================
          // CONTENT
          // ==================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOCATION
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D2E),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.06,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: const Color(0xFF26333C),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF80D6D4),
                          size: 21,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR RENTAL STATION',
                              style: TextStyle(
                                color:
                                    Color(0xFF8F93A3),
                                fontSize: 9,
                                letterSpacing: 1.2,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Azuela Cove',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16312C),
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: Color(0xFFAAD9BB),
                              size: 7,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'OPEN',
                              style: TextStyle(
                                color:
                                    Color(0xFFAAD9BB),
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // AVAILABLE HEADER
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AVAILABLE NEAR YOU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '3 bikes ready to ride',
                            style: TextStyle(
                              color: Color(0xFF9396A6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    TextButton(
                      onPressed: () => onTab(1),
                      child: const Text(
                        'See all →',
                        style: TextStyle(
                          color: Color(0xFF80D6D4),
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // BIKE 1
                _DarkHomeBikeCard(
                  bike: availableBikes[0],
                  onTap: () =>
                      onBike(availableBikes[0]),
                ),

                const SizedBox(height: 12),

                // BIKE 2
                _DarkHomeBikeCard(
                  bike: availableBikes[1],
                  onTap: () =>
                      onBike(availableBikes[1]),
                ),

                const SizedBox(height: 12),

                // BIKE 3
                _DarkHomeBikeCard(
                  bike: availableBikes[2],
                  onTap: () =>
                      onBike(availableBikes[2]),
                ),

                const SizedBox(height: 26),

                // SAFETY
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF17292B),
                        Color(0xFF20243A),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF80BCBD)
                          .withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Color(0xFFAAD9BB),
                        size: 25,
                      ),

                      SizedBox(width: 11),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RIDE SMART',
                              style: TextStyle(
                                color:
                                    Color(0xFFAAD9BB),
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Stay inside the allowed riding zone and always wear a helmet.',
                              style: TextStyle(
                                color:
                                    Color(0xFFC6C8D1),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkHomeBikeCard extends StatelessWidget {
  final BikeVariantData bike;
  final VoidCallback onTap;

  const _DarkHomeBikeCard({
    required this.bike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price =
        bike.price.replaceFirst('PHP ', '₱');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D2E),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.06,
              ),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: Image.asset(
                    bike.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF16312C),
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                          child: const Text(
                            '● AVAILABLE',
                            style: TextStyle(
                              color:
                                  Color(0xFFAAD9BB),
                              fontSize: 8,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),

                        const Spacer(),

                        Text(
                          bike.id,
                          style: const TextStyle(
                            color:
                                Color(0xFF8E91A1),
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Text(
                      bike.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF9699A8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          bike.range,
                          style: const TextStyle(
                            color: Color(0xFF9699A8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            price,
                            style: const TextStyle(
                              color: Color(0xFF80D6D4),
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),

                        Container(
                          width: 33,
                          height: 33,
                          decoration:
                              const BoxDecoration(
                            color: Color(0xFFAAD9BB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons
                                .arrow_forward_rounded,
                            color: Color(0xFF171827),
                            size: 17,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const HomeQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: ink,
                size: 24,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Bikes extends StatefulWidget {
  final ValueChanged<BikeVariantData> onBike;

  const Bikes({
    super.key,
    required this.onBike,
  });

  @override
  State<Bikes> createState() => _BikesState();
}

class _BikesState extends State<Bikes> {
  String selectedFilter = 'All';
  String searchQuery = '';

  final List<BikeVariantData> bikes = const [
    BikeVariantData(
      variant: BikeVariant.kids,
      name: 'Kids Bike',
      id: 'K-001',
      range: 'Age 4–8',
      price: 'PHP 30 / 30 mins',
      accentColor: Color(0xFFBFEFE9),
      bodyColor: Color(0xFF5EC9D4),
      imagePath: 'assets/images/kids_bike.jpg',
    ),

    BikeVariantData(
      variant: BikeVariant.doubleBike,
      name: 'Double Bike',
      id: 'D-204',
      range: '2 riders',
      price: 'PHP 70 / 30 mins',
      accentColor: Color(0xFFE3F4F1),
      bodyColor: Color(0xFF7BCFCF),
      imagePath: 'assets/images/double_bike.jpg',
    ),

    BikeVariantData(
      variant: BikeVariant.standard,
      name: 'Normal Bike',
      id: 'N-118',
      range: '1 rider',
      price: 'PHP 50 / 30 mins',
      accentColor: Color(0xFFEAF8F4),
      bodyColor: Color(0xFF5FC5C8),
      imagePath: 'assets/images/normal_bike.jpg',
    ),
  ];

  List<BikeVariantData> get filteredBikes {
    return bikes.where((bike) {
      bool matchesFilter = true;

      if (selectedFilter == 'Kids') {
        matchesFilter =
            bike.variant == BikeVariant.kids;
      } else if (selectedFilter == 'Normal') {
        matchesFilter =
            bike.variant == BikeVariant.standard;
      } else if (selectedFilter == 'Double') {
        matchesFilter =
            bike.variant == BikeVariant.doubleBike;
      }

      final query = searchQuery.toLowerCase();

      final matchesSearch =
          bike.name.toLowerCase().contains(query) ||
          bike.id.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleBikes = filteredBikes;

    return Container(
      color: const Color(0xFF0B0D18),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          28,
          20,
          30,
        ),
        children: [
          // ======================================
          // HEADER
          // ======================================

          const Text(
            'Find your ride',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Choose the bicycle that fits your next adventure.',
            style: TextStyle(
              color: Color(0xFF9699A8),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 22),

          // ======================================
          // SEARCH BAR
          // ======================================

          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Search bike or ID',
              hintStyle: const TextStyle(
                color: Color(0xFF777B8E),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF80D6D4),
              ),
              filled: true,
              fillColor: const Color(0xFF1A1D2E),

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.white.withValues(
                    alpha: 0.06,
                  ),
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFF80BCBD),
                  width: 1.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ======================================
          // FILTERS
          // ======================================

          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _BikeFilterChip(
                label: 'All',
                selected:
                    selectedFilter == 'All',
                onTap: () {
                  setState(() {
                    selectedFilter = 'All';
                  });
                },
              ),

              _BikeFilterChip(
                label: 'Kids',
                selected:
                    selectedFilter == 'Kids',
                onTap: () {
                  setState(() {
                    selectedFilter = 'Kids';
                  });
                },
              ),

              _BikeFilterChip(
                label: 'Normal',
                selected:
                    selectedFilter == 'Normal',
                onTap: () {
                  setState(() {
                    selectedFilter = 'Normal';
                  });
                },
              ),

              _BikeFilterChip(
                label: 'Double',
                selected:
                    selectedFilter == 'Double',
                onTap: () {
                  setState(() {
                    selectedFilter = 'Double';
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ======================================
          // AVAILABILITY BANNER
          // ======================================

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF17292B),
                  Color(0xFF20243A),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    color: const Color(0xFF292D43),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.pedal_bike_rounded,
                    color: Color(0xFF80D6D4),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${visibleBikes.length} bikes available',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Ready to ride at Azuela Cove',
                        style: TextStyle(
                          color:
                              Color(0xFF9699A8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFFAAD9BB),
                  size: 25,
                ),
              ],
            ),
          ),

          const SizedBox(height: 27),

          // ======================================
          // AVAILABLE BICYCLES HEADER
          // ======================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Available bicycles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),

              Text(
                '${visibleBikes.length} available',
                style: const TextStyle(
                  color: Color(0xFF80D6D4),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // ======================================
          // BIKE LIST
          // ======================================

          if (visibleBikes.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 40,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D2E),
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    color: Color(0xFF9699A8),
                    size: 34,
                  ),

                  SizedBox(height: 10),

                  Text(
                    'No bikes found',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Try another bike type or search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9699A8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
          else
            ...visibleBikes.map(
              (bike) => Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child: _DarkBikesCard(
                  bike: bike,
                  onTap: () {
                    widget.onBike(bike);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BikeFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BikeFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFAAD9BB)
              : const Color(0xFF1A1D2E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? const Color(0xFFAAD9BB)
                : const Color(0xFF303347),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFF171827)
                : const Color(0xFFC6C8D1),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DarkBikesCard extends StatelessWidget {
  final BikeVariantData bike;
  final VoidCallback onTap;

  const _DarkBikesCard({
    required this.bike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayPrice =
        bike.price.replaceFirst('PHP ', '₱');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D2E),
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.06,
              ),
            ),
          ),
          child: Row(
            children: [
              // BIKE IMAGE
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(16),
                child: SizedBox(
                  width: 91,
                  height: 91,
                  child: Image.asset(
                    bike.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              // BIKE INFO
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      bike.id,
                      style: const TextStyle(
                        color:
                            Color(0xFF80D6D4),
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      bike.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      bike.range,
                      style: const TextStyle(
                        color:
                            Color(0xFF9699A8),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      displayPrice,
                      style: const TextStyle(
                        color:
                            Color(0xFFAAD9BB),
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ARROW
              Container(
                width: 42,
                height: 42,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFAAD9BB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF171827),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BikeCard extends StatelessWidget {
  final String id;
  final String label;
  final String range;
  final String price;
  final String imagePath;
  final BikeVariant variant;
  final VoidCallback onTap;

  const BikeCard({
    super.key,
    required this.id,
    required this.label,
    required this.range,
    required this.price,
    required this.imagePath,
    required this.variant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = variant == BikeVariant.kids
        ? const Color(0xFFB8F0E3)
        : variant == BikeVariant.doubleBike
            ? const Color(0xFFEAF7F3)
            : const Color(0xFFE8F9F1);

    return CardBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 86,
            height: 76,
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: BikeIllustration(variant: variant, imagePath: imagePath, size: 60),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(id, style: const TextStyle(fontSize: 16, color: ink, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 1),
                  Text(label, style: const TextStyle(fontSize: 18, color: ink, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 1),
                  Text(range, style: const TextStyle(color: muted, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 1),
                  Text(price, style: const TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded, size: 22),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFBFE6C9),
                foregroundColor: ink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BikeDetails extends StatefulWidget {
  final BikeVariantData bike;
  final VoidCallback onBack;
  final void Function(String duration, int cost) onReserve;

  const BikeDetails({
    super.key,
    required this.bike,
    required this.onBack,
    required this.onReserve,
  });

  @override
  State<BikeDetails> createState() => _BikeDetailsState();
}

class _BikeDetailsState extends State<BikeDetails> {
  String selectedDuration = '30 minutes';

    final List<String> durations = [
    '30 minutes',
    '1 hour',
    '2 hours',
    'Custom',
  ];

  int get ratePer30Minutes {
  switch (widget.bike.variant) {
    case BikeVariant.kids:
      return 30;

    case BikeVariant.doubleBike:
      return 70;

    case BikeVariant.standard:
      return 50;
  }
}

int get estimatedCost {
  switch (selectedDuration) {
    case '30 minutes':
      return ratePer30Minutes;

    case '1 hour':
      return ratePer30Minutes * 2;

    case '2 hours':
      return ratePer30Minutes * 4;

    default:
      return ratePer30Minutes;
  }
}


@override
Widget build(BuildContext context) {
  final displayRate = '₱$ratePer30Minutes / 30 min';
  final displayTotal = '₱$estimatedCost.00';

  return AppPage(
    onBack: widget.onBack,
    child: Container(
      color: const Color(0xFF0B0D18),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 58, 22, 28),
        children: [
          // =========================
          // BIKE IMAGE
          // =========================

          Container(
            height: 235,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.bike.imagePath,
                  fit: BoxFit.cover,
                ),

                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x22000000),
                        Color(0x990B0D18),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xE61A1D2E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Color(0xFF80D6D4),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Azuela Cove',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 21),

          // =========================
          // BIKE NAME
          // =========================

          Text(
            widget.bike.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: Color(0xFF9699A8),
              ),
              const SizedBox(width: 5),

              Text(
                widget.bike.range,
                style: const TextStyle(
                  color: Color(0xFF9699A8),
                  fontSize: 13,
                ),
              ),

              const SizedBox(width: 15),

              const Icon(
                Icons.gps_fixed_rounded,
                size: 15,
                color: Color(0xFF80D6D4),
              ),

              const SizedBox(width: 5),

              const Text(
                'GPS tracked',
                style: TextStyle(
                  color: Color(0xFF9699A8),
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // =========================
          // RENTAL RATE
          // =========================

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF17292B),
                  Color(0xFF20243A),
                ],
              ),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF293044),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: Color(0xFF80D6D4),
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Text(
                    'Rental rate',
                    style: TextStyle(
                      color: Color(0xFF9EA1B0),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Text(
                  displayRate,
                  style: const TextStyle(
                    color: Color(0xFFAAD9BB),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // =========================
          // DURATION
          // =========================

          const Text(
            'Choose your ride time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Select how long you want to rent this bike.',
            style: TextStyle(
              color: Color(0xFF9699A8),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: durations.map((duration) {
              final isSelected =
                  selectedDuration == duration;

              return ChoiceChip(
                label: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  child: Text(duration),
                ),

                selected: isSelected,
                showCheckmark: false,

                selectedColor:
                    const Color(0xFFAAD9BB),

                backgroundColor:
                    const Color(0xFF1A1D2E),

                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFAAD9BB)
                      : Colors.white.withValues(
                          alpha: 0.09,
                        ),
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF171827)
                      : const Color(0xFFD2D4DC),
                  fontWeight: isSelected
                      ? FontWeight.w900
                      : FontWeight.w600,
                ),

                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      selectedDuration = duration;
                    });
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 27),

          // =========================
          // ESTIMATED TOTAL
          // =========================

          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(23),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Selected duration',
                        style: TextStyle(
                          color: Color(0xFF9EA1B0),
                          fontSize: 13,
                        ),
                      ),
                    ),

                    Text(
                      selectedDuration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Divider(
                  color: Colors.white.withValues(
                    alpha: 0.08,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Text(
                        'Estimated total',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    Text(
                      displayTotal,
                      style: const TextStyle(
                        color: Color(0xFFAAD9BB),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 17),

          // =========================
          // SAFETY
          // =========================

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF17292B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.18),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  color: Color(0xFFAAD9BB),
                  size: 21,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Check the brakes and wear a helmet before starting your ride.',
                    style: TextStyle(
                      color: Color(0xFFC5C8D2),
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // RESERVE BUTTON
          // =========================

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                widget.onReserve(
                  selectedDuration,
                  estimatedCost,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFAAD9BB),
                foregroundColor:
                    const Color(0xFF171827),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pedal_bike_rounded,
                    size: 19,
                  ),

                  SizedBox(width: 8),

                  Text(
                    'Reserve this Bike',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(width: 7),

                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class Reservation extends StatefulWidget {
  final BikeVariantData bike;
  final String duration;
  final int estimatedCost;
  final String riderName;
  final VoidCallback onBack;

  final void Function(String paymentMethod) onContinue;

  const Reservation({
    super.key,
    required this.bike,
    required this.duration,
    required this.estimatedCost,
    required this.riderName,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<Reservation> createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  String selectedPayment = 'online';

@override
Widget build(BuildContext context) {
  return AppPage(
    onBack: widget.onBack,
    child: Container(
  color: const Color(0xFF0B0D18),
  child: ListView(
    padding: const EdgeInsets.fromLTRB(20, 62, 20, 28),
    children: [
        // HEADER
        const Text(
          'Almost ready! 🚲',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Review your ride and choose how you want to pay.',
          style: TextStyle(
            color: Color(0xFF9699A8),
            fontSize: 14,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 22),

        // PROGRESS
        Row(
          children: [
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFAAD9BB),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D43),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Row(
          children: [
            Expanded(
              child: Text(
                'Bike',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Review',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Payment',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // BIKE SUMMARY
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D2E),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12214645),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Image.asset(
                    widget.bike.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16312C),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        '● Reserved for you',
                        style: TextStyle(
                          color: Color(0xFFAAD9BB),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      widget.bike.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${widget.bike.id} • ${widget.duration}',
                      style: const TextStyle(
                        color:  Color(0xFF9699A8),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: muted,
                          size: 14,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Azuela Cove',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Ride summary',
          style: TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 12),
Container(
  padding: const EdgeInsets.all(17),
  decoration: BoxDecoration(
    color: const Color(0xFF1A1D2E),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.06),
    ),
  ),
  child: Column(
    children: [
      // RIDER
      Row(
        children: [
          const Expanded(
            child: Text(
              'Rider',
              style: TextStyle(
                color: Color(0xFF9699A8),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            widget.riderName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      // DURATION
      Row(
        children: [
          const Expanded(
            child: Text(
              'Duration',
              style: TextStyle(
                color: Color(0xFF9699A8),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            widget.duration,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      // START TIME
      const Row(
        children: [
          Expanded(
            child: Text(
              'Start time',
              style: TextStyle(
                color: Color(0xFF9699A8),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            'Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),

      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),

      // TOTAL
      Row(
        children: [
          const Expanded(
            child: Text(
              'Estimated total',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          Text(
            '₱${widget.estimatedCost}.00',
            style: const TextStyle(
              color: Color(0xFFAAD9BB),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ],
  ),
),

        const SizedBox(height: 25),

        const Text(
          'How would you like to pay?',
          style: TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Choose your preferred payment method.',
          style: TextStyle(
            color: muted,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 13),

        // ONLINE PAYMENT
        InkWell(
          onTap: () {
            setState(() {
              selectedPayment = 'online';
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: selectedPayment == 'online'
    ? const Color(0xFF17292B)
    : const Color(0xFF1A1D2E),
             border: Border.all(
  color: selectedPayment == 'online'
      ? const Color(0xFFAAD9BB)
      : const Color(0xFF2E3145),
  width: selectedPayment == 'online' ? 2 : 1,
),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF292D43),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF80D6D4),
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Online payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pay securely using GCash',
                        style: TextStyle(
                          color: Color(0xFF9699A8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  selectedPayment == 'online'
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_off_rounded,
                  color: selectedPayment == 'online'
                      ? const Color(0xFFAAD9BB)
    : const Color(0xFF9699A8),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // PAY AT STATION
        InkWell(
          onTap: () {
            setState(() {
              selectedPayment = 'station';
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: selectedPayment == 'station'
                  ? const Color(0xFF17292B)
    : const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(20),
             border: Border.all(
  color: selectedPayment == 'station'
      ? const Color(0xFFAAD9BB)
      : const Color(0xFF2E3145),
  width: selectedPayment == 'station' ? 2 : 1,
),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color:const Color(0xFF292D43),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Color(0xFF80D6D4),
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay at rental station',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pay when you arrive',
                        style: TextStyle(
                          color: Color(0xFF9699A8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  selectedPayment == 'station'
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_off_rounded,
                  color: selectedPayment == 'station'
                      ? const Color(0xFFAAD9BB)
    : const Color(0xFF9699A8),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFF17292B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: Color(0xFFAAD9BB),
                size: 20,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Your selected bicycle will be held for 10 minutes.',
                  style: TextStyle(
                    color: Color(0xFFC6C8D1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        MainButton(
          label: selectedPayment == 'online'
              ? 'Continue to Payment'
              : 'Confirm Reservation',
          icon: selectedPayment == 'online'
              ? Icons.arrow_forward_rounded
              : Icons.check_rounded,
          onTap: () {
            widget.onContinue(selectedPayment);
          },
        ),
      ],
    ),
  ),
  );
}
}


class Payment extends StatelessWidget {
  final BikeVariantData bike;
  final String duration;
  final int totalAmount;
  final VoidCallback onBack;
  final VoidCallback onDone;

  const Payment({
    super.key,
    required this.bike,
    required this.duration,
    required this.totalAmount,
    required this.onBack,
    required this.onDone,
  });

  int get ratePer30Minutes {
    switch (bike.variant) {
      case BikeVariant.kids:
        return 30;
      case BikeVariant.doubleBike:
        return 70;
      case BikeVariant.standard:
        return 50;
    }
  }

  @override
Widget build(BuildContext context) {
  return AppPage(
    onBack: onBack,
    child: Container(
      color: const Color(0xFF0B0D18),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 62, 20, 28),
        children: [
          // =========================
          // PROGRESS
          // =========================

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAAD9BB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAAD9BB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAAD9BB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Row(
            children: [
              Expanded(
                child: Text(
                  'Bike',
                  style: TextStyle(
                    color: Color(0xFF9699A8),
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Review',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9699A8),
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Payment',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // =========================
          // HEADER
          // =========================

          const Text(
            'Complete payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'One last step before your ride begins.',
            style: TextStyle(
              color: Color(0xFF9699A8),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 22),

          // =========================
          // BIKE CARD
          // =========================

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 82,
                    height: 82,
                    child: Image.asset(
                      bike.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bike.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${bike.id} • $duration',
                        style: const TextStyle(
                          color: Color(0xFF9699A8),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF80D6D4),
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Azuela Cove',
                            style: TextStyle(
                              color: Color(0xFF9699A8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // PAYMENT SUMMARY
          // =========================

          const Text(
            'Payment summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: [
                _DarkPaymentDetail(
                  label: 'Rental rate',
                  value: '₱$ratePer30Minutes / 30 min',
                ),

                const SizedBox(height: 12),

                _DarkPaymentDetail(
                  label: 'Duration',
                  value: duration,
                ),

                const SizedBox(height: 12),

                const _DarkPaymentDetail(
                  label: 'Additional charges',
                  value: '₱0.00',
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // =========================
          // TOTAL
          // =========================

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF173033),
                  Color(0xFF20243A),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL AMOUNT',
                        style: TextStyle(
                          color: Color(0xFF80D6D4),
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Amount to pay',
                        style: TextStyle(
                          color: Color(0xFF9699A8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '₱$totalAmount.00',
                  style: const TextStyle(
                    color: Color(0xFFAAD9BB),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // =========================
          // PAY WITH
          // =========================

          const Text(
            'Pay with',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF17292B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFAAD9BB),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF292D43),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF80D6D4),
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GCash',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'E-Wallet •••• 2081',
                        style: TextStyle(
                          color: Color(0xFF9699A8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFFAAD9BB),
                  size: 25,
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // =========================
          // SECURITY NOTE
          // =========================

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFF17292B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFFAAD9BB),
                  size: 20,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Your payment information is securely protected.',
                    style: TextStyle(
                      color: Color(0xFFC6C8D1),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // PAY BUTTON
          // =========================

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAAD9BB),
                foregroundColor: const Color(0xFF171827),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pay ₱$totalAmount.00',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              'You will be taken to your active ride after payment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9699A8),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _DarkPaymentDetail extends StatelessWidget {
  final String label;
  final String value;

  const _DarkPaymentDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9699A8),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class ActiveRide extends StatefulWidget {
  final BikeVariantData bike;
  final String duration;
  final int baseAmount;
  final DateTime startTime;
  final bool extended;
  final VoidCallback onBack;
  final VoidCallback onExtend;
  final VoidCallback onReturn;

  const ActiveRide({
    super.key,
    required this.bike,
    required this.duration,
    required this.baseAmount,
    required this.startTime,
    required this.extended,
    required this.onBack,
    required this.onExtend,
    required this.onReturn,
  });

  @override
  State<ActiveRide> createState() => _ActiveRideState();
}


class _ActiveRideState extends State<ActiveRide> {
  Timer? _timer;

  Duration elapsed = Duration.zero;

  final LatLng zoneCenter = const LatLng(
    7.10225,
    125.64479,
  );

  LatLng bikeLocation = const LatLng(
    7.10225,
    125.64479,
  );

  final List<LatLng> allowedZone = const [
    LatLng(7.10310, 125.64410),
    LatLng(7.10305, 125.64520),
    LatLng(7.10255, 125.64565),
    LatLng(7.10175, 125.64545),
    LatLng(7.10145, 125.64455),
    LatLng(7.10195, 125.64395),
  ];

  @override
  void initState() {
    super.initState();

    _updateTimer();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _updateTimer();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ==========================================================
  // RENTAL TIME
  // ==========================================================

  Duration get totalDuration {
    switch (widget.duration) {
      case '30 minutes':
        return const Duration(minutes: 30);

      case '1 hour':
        return const Duration(hours: 1);

      case '2 hours':
        return const Duration(hours: 2);

      default:
        return const Duration(minutes: 30);
    }
  }

  Duration get remainingTime {
    final remaining = totalDuration - elapsed;

    if (remaining.isNegative) {
      return Duration.zero;
    }

    return remaining;
  }

  int get additionalCharge {
    return widget.extended ? 25 : 0;
  }

  int get currentTotal {
    return widget.baseAmount + additionalCharge;
  }

  void _updateTimer() {
    if (!mounted) return;

    setState(() {
      elapsed = DateTime.now().difference(
        widget.startTime,
      );
    });
  }

  String _formatTime(Duration duration) {
    final hours =
        duration.inHours.toString().padLeft(2, '0');

    final minutes =
        (duration.inMinutes % 60)
            .toString()
            .padLeft(2, '0');

    final seconds =
        (duration.inSeconds % 60)
            .toString()
            .padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  double get rideProgress {
    if (totalDuration.inSeconds <= 0) {
      return 0;
    }

    return (elapsed.inSeconds /
            totalDuration.inSeconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  // ==========================================================
  // GEOFENCE
  // ==========================================================

  bool _isPointInsidePolygon(
    LatLng point,
    List<LatLng> polygon,
  ) {
    if (polygon.length < 3) {
      return false;
    }

    bool inside = false;

    for (
      int i = 0, j = polygon.length - 1;
      i < polygon.length;
      j = i++
    ) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;

      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      final intersects =
          ((yi > point.latitude) !=
                  (yj > point.latitude)) &&
              (point.longitude <
                  (xj - xi) *
                          (point.latitude - yi) /
                          (yj - yi) +
                      xi);

      if (intersects) {
        inside = !inside;
      }
    }

    return inside;
  }

  bool get isOutsideZone {
    return !_isPointInsidePolygon(
      bikeLocation,
      allowedZone,
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final bool pulse = elapsed.inSeconds.isEven;

    return AppPage(
      onBack: widget.onBack,
      child: Container(
        color: const Color(0xFF0B0D18),
        child: Column(
          children: [
            // ==================================================
            // SCROLLABLE CONTENT
            // ==================================================

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  62,
                  20,
                  18,
                ),
                children: [
                  // ============================================
                  // HEADER
                  // ============================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Live ride',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '${widget.bike.name} • ${widget.bike.id}',
                              style: const TextStyle(
                                color: Color(
                                  0xFF9699A8,
                                ),
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ACTIVE / OUTSIDE ZONE BADGE
                      AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isOutsideZone
                              ? const Color(0xFF40191E)
                              : const Color(0xFF16312C),
                          borderRadius:
                              BorderRadius.circular(30),
                          border: Border.all(
                            color: isOutsideZone
                                ? Colors.red.withValues(
                                    alpha: 0.45,
                                  )
                                : const Color(
                                    0xFFAAD9BB,
                                  ).withValues(
                                    alpha: 0.20,
                                  ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: isOutsideZone
                                  ? const Color(
                                      0xFFFF6464,
                                    )
                                  : const Color(
                                      0xFFAAD9BB,
                                    ),
                            ),

                            const SizedBox(width: 6),

                            Text(
                              isOutsideZone
                                  ? 'OUTSIDE ZONE'
                                  : 'ACTIVE',
                              style: TextStyle(
                                color: isOutsideZone
                                    ? const Color(
                                        0xFFFF7D7D,
                                      )
                                    : const Color(
                                        0xFFAAD9BB,
                                      ),
                                fontSize: 10,
                                letterSpacing: 0.4,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ============================================
                  // LIVE MAP
                  // ============================================

                  Container(
                    height: 270,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter:
                                  zoneCenter,
                              initialZoom: 17,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.pedalya_mobile',
                              ),

                              // ==================================
                              // RED GEOFENCE
                              // ==================================

                              PolygonLayer(
                                polygons: [
                                  Polygon(
                                    points: allowedZone,
                                    color: isOutsideZone
                                        ? Colors.red
                                            .withValues(
                                            alpha: 0.10,
                                          )
                                        : const Color(
                                            0xFF80BCBD,
                                          ).withValues(
                                            alpha: 0.16,
                                          ),
                                    borderColor:
                                        Colors.red,
                                    borderStrokeWidth:
                                        5,
                                  ),
                                ],
                              ),

                              // ==================================
                              // BIKE GPS MARKER
                              // ==================================

                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point:
                                        bikeLocation,
                                    width: 70,
                                    height: 70,
                                    child: Center(
                                      child:
                                          AnimatedContainer(
                                        duration:
                                            const Duration(
                                          milliseconds:
                                              750,
                                        ),
                                        width:
                                            pulse
                                                ? 62
                                                : 52,
                                        height:
                                            pulse
                                                ? 62
                                                : 52,
                                        alignment:
                                            Alignment
                                                .center,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              (isOutsideZone
                                                      ? Colors
                                                          .red
                                                      : const Color(
                                                          0xFFAAD9BB,
                                                        ))
                                                  .withValues(
                                            alpha: 0.24,
                                          ),
                                          shape: BoxShape
                                              .circle,
                                        ),
                                        child:
                                            Container(
                                          width: 44,
                                          height: 44,
                                          decoration:
                                              BoxDecoration(
                                            color: isOutsideZone
                                                ? Colors
                                                    .red
                                                : const Color(
                                                    0xFF1A1D2E,
                                                  ),
                                            shape:
                                                BoxShape
                                                    .circle,
                                            border:
                                                Border
                                                    .all(
                                              color: Colors
                                                  .white,
                                              width: 3,
                                            ),
                                          ),
                                          child:
                                              const Icon(
                                            Icons
                                                .pedal_bike_rounded,
                                            color: Colors
                                                .white,
                                            size: 21,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // =========================================
                        // LIVE GPS LABEL
                        // =========================================

                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors.white
                                  .withValues(
                                alpha: 0.94,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(14),
                            ),
                            child: const Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons
                                      .gps_fixed_rounded,
                                  color: primary,
                                  size: 17,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'LIVE GPS',
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // =========================================
                        // INSIDE / OUTSIDE ZONE LABEL
                        // =========================================

                        Positioned(
                          left: 12,
                          bottom: 12,
                          child:
                              AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds: 250,
                            ),
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration:
                                BoxDecoration(
                              color: isOutsideZone
                                  ? Colors.red
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius
                                      .circular(14),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Icon(
                                  isOutsideZone
                                      ? Icons
                                          .warning_rounded
                                      : Icons
                                          .check_circle_rounded,
                                  size: 18,
                                  color:
                                      isOutsideZone
                                          ? Colors.white
                                          : const Color(
                                              0xFF2E7D32,
                                            ),
                                ),

                                const SizedBox(
                                  width: 6,
                                ),

                                Text(
                                  isOutsideZone
                                      ? 'Outside allowed zone'
                                      : 'Inside allowed zone',
                                  style:
                                      TextStyle(
                                    color:
                                        isOutsideZone
                                            ? Colors
                                                .white
                                            : ink,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          right: 6,
                          bottom: 5,
                          child: Container(
                            padding:
                                const EdgeInsets
                                    .all(3),
                            color: Colors.white70,
                            child: const Text(
                              '© OpenStreetMap',
                              style: TextStyle(
                                color:
                                    Colors.black54,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ============================================
                  // OUTSIDE ZONE WARNING
                  // ============================================

                  if (isOutsideZone) ...[
                    Container(
                      padding:
                          const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF3A171D,
                        ),
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.red.withValues(
                            alpha: 0.40,
                          ),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Color(
                              0xFFFF6B6B,
                            ),
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  'You are outside the allowed riding zone.',
                                  style: TextStyle(
                                    color: Color(
                                      0xFFFF7D7D,
                                    ),
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                  ),
                                ),

                                SizedBox(height: 3),

                                Text(
                                  'Please return inside the red boundary.',
                                  style: TextStyle(
                                    color: Color(
                                      0xFFD7D8DE,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],

                  // ============================================
                  // RIDE TIMER
                  // ============================================

                  Container(
                    padding:
                        const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF1A1D2E,
                      ),
                      borderRadius:
                          BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white
                            .withValues(
                          alpha: 0.06,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Color(
                                0xFF80D6D4,
                              ),
                              size: 18,
                            ),

                            SizedBox(width: 6),

                            Text(
                              'RIDE TIME',
                              style: TextStyle(
                                color: Color(
                                  0xFF80D6D4,
                                ),
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 9),

                        Text(
                          _formatTime(elapsed),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '${_formatTime(remainingTime)} remaining',
                          style: const TextStyle(
                            color: Color(
                              0xFF9699A8,
                            ),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 17),

                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                          child:
                              LinearProgressIndicator(
                            value: rideProgress,
                            minHeight: 8,
                            backgroundColor:
                                Colors.white
                                    .withValues(
                              alpha: 0.10,
                            ),
                            color: const Color(
                              0xFFAAD9BB,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Text(
                              '${(rideProgress * 100).round()}% used',
                              style:
                                  const TextStyle(
                                color: Color(
                                  0xFF9699A8,
                                ),
                                fontSize: 11,
                              ),
                            ),

                            const Spacer(),

                            Text(
                              widget.duration,
                              style:
                                  const TextStyle(
                                color: Color(
                                  0xFF9699A8,
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ============================================
                  // RENTAL SUMMARY
                  // ============================================

                  const Text(
                    'Rental summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 11),

                  Container(
                    padding:
                        const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF1A1D2E,
                      ),
                      borderRadius:
                          BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white
                            .withValues(
                          alpha: 0.06,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // BASE RENTAL
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Base rental',
                                style:
                                    TextStyle(
                                  color: Color(
                                    0xFF9699A8,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            Text(
                              '₱${widget.baseAmount}.00',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 14,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 13),

                        // EXTRA TIME
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Extra time',
                                style:
                                    TextStyle(
                                  color: Color(
                                    0xFF9699A8,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            Text(
                              '₱$additionalCharge.00',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 14,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 12,
                          ),
                          child: Divider(
                            color: Colors.white
                                .withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),

                        // CURRENT TOTAL
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Current total',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                            ),

                            Text(
                              '₱$currentTotal.00',
                              style:
                                  const TextStyle(
                                color: Color(
                                  0xFFAAD9BB,
                                ),
                                fontSize: 23,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ============================================
                  // SAFETY MESSAGE
                  // ============================================

                  Container(
                    padding:
                        const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isOutsideZone
                          ? const Color(
                              0xFF3A171D,
                            )
                          : const Color(
                              0xFF17292B,
                            ),
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color: isOutsideZone
                            ? Colors.red
                                .withValues(
                                alpha: 0.30,
                              )
                            : const Color(
                                0xFF80BCBD,
                              ).withValues(
                                alpha: 0.15,
                              ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isOutsideZone
                              ? Icons
                                  .warning_amber_rounded
                              : Icons
                                  .health_and_safety_outlined,
                          color: isOutsideZone
                              ? const Color(
                                  0xFFFF6B6B,
                                )
                              : const Color(
                                  0xFFAAD9BB,
                                ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            isOutsideZone
                                ? 'Return inside the red rental boundary as soon as possible.'
                                : 'Stay inside the red rental boundary during your ride.',
                            style: TextStyle(
                              color: isOutsideZone
                                  ? const Color(
                                      0xFFFF8A8A,
                                    )
                                  : const Color(
                                      0xFFC6C8D1,
                                    ),
                              fontSize: 13,
                              height: 1.35,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ============================================
                  // HELP BUTTON
                  // ============================================

                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Help request feature will be connected to the Pedalya admin later.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.support_agent_rounded,
                    ),
                    label: const Text(
                      'Need help?',
                    ),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(
                        0xFF80D6D4,
                      ),
                      backgroundColor:
                          const Color(
                        0xFF1A1D2E,
                      ),
                      minimumSize:
                          const Size.fromHeight(
                        50,
                      ),
                      side: const BorderSide(
                        color: Color(
                          0xFF80BCBD,
                        ),
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                      textStyle:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // DARK STICKY BOTTOM ACTIONS
            // ==================================================

            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF0B0D18,
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white
                        .withValues(
                      alpha: 0.05,
                    ),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // EXTEND RIDE
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed:
                            widget.onExtend,
                        style: OutlinedButton
                            .styleFrom(
                          foregroundColor:
                              const Color(
                            0xFF80D6D4,
                          ),
                          backgroundColor:
                              const Color(
                            0xFF1A1D2E,
                          ),
                          side:
                              const BorderSide(
                            color: Color(
                              0xFF80BCBD,
                            ),
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              17,
                            ),
                          ),
                        ),
                        child: Text(
                          widget.extended
                              ? 'Extension added'
                              : 'Extend ride',
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // RETURN BIKE
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            widget.onReturn,
                        icon: const Icon(
                          Icons
                              .lock_outline_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Return Bike',
                        ),
                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFAAD9BB,
                          ),
                          foregroundColor:
                              const Color(
                            0xFF171827,
                          ),
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              17,
                            ),
                          ),
                          textStyle:
                              const TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
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

class ReturnBike extends StatelessWidget {
  final BikeVariantData bike;
  final int baseAmount;
  final DateTime startTime;
  final bool extended;
  final VoidCallback onBack;
  final VoidCallback onDone;

  const ReturnBike({
    super.key,
    required this.bike,
    required this.baseAmount,
    required this.startTime,
    required this.extended,
    required this.onBack,
    required this.onDone,
  });

  int get additionalCharge {
    return extended ? 25 : 0;
  }

  int get finalAmount {
    return baseAmount + additionalCharge;
  }

  String _formatClockTime(DateTime time) {
    int hour = time.hour;
    final minute =
        time.minute.toString().padLeft(2, '0');

    final period =
        hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    return '$hour:$minute $period';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes =
        duration.inMinutes.remainder(60);

    if (hours == 0) {
      return '$minutes min';
    }

    if (minutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final returnTime = DateTime.now();

    final totalDuration =
        returnTime.difference(startTime);

    return AppPage(
      onBack: onBack,
      child: Container(
        color: const Color(0xFF0B0D18),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            62,
            20,
            30,
          ),
          children: [
            // =========================================
            // HEADER
            // =========================================

            const Text(
              'Finish your ride',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Return the bicycle safely to complete your rental.',
              style: TextStyle(
                color: Color(0xFF9699A8),
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 22),

            // =========================================
            // BIKE CARD
            // =========================================

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D2E),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.06,
                  ),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(16),
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: Image.asset(
                        bike.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF332E20),
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'READY TO RETURN',
                            style: TextStyle(
                              color:
                                  Color(0xFFF9F7C9),
                              fontSize: 8,
                              letterSpacing: 0.6,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          bike.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          bike.id,
                          style: const TextStyle(
                            color:
                                Color(0xFF9699A8),
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Row(
                          children: [
                            Icon(
                              Icons
                                  .location_on_outlined,
                              color: Color(
                                0xFF80D6D4,
                              ),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Azuela Cove',
                              style: TextStyle(
                                color: Color(
                                  0xFF9699A8,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // =========================================
            // BEFORE YOU FINISH
            // =========================================

            const Text(
              'Before you finish',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 11),

            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFF17292B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color:
                      const Color(0xFF80BCBD)
                          .withValues(
                    alpha: 0.15,
                  ),
                ),
              ),
              child: const Column(
                children: [
                  _ReturnStep(
                    number: '1',
                    title:
                        'Return to the station',
                    subtitle:
                        'Bring the bicycle back to the designated Pedalya area.',
                  ),

                  SizedBox(height: 18),

                  _ReturnStep(
                    number: '2',
                    title:
                        'Park the bicycle properly',
                    subtitle:
                        'Place the bicycle safely at the rental station.',
                  ),

                  SizedBox(height: 18),

                  _ReturnStep(
                    number: '3',
                    title:
                        'Secure the bicycle',
                    subtitle:
                        'Make sure the bicycle is ready to be locked before confirming.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 27),

            // =========================================
            // RIDE SUMMARY
            // =========================================

            const Text(
              'Ride summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 11),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D2E),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.06,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // RENTAL STARTED
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Rental started',
                          style: TextStyle(
                            color:
                                Color(0xFF9699A8),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      Text(
                        _formatClockTime(startTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // RETURN TIME
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Return time',
                          style: TextStyle(
                            color:
                                Color(0xFF9699A8),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      Text(
                        _formatClockTime(returnTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // RIDE DURATION
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Ride duration',
                          style: TextStyle(
                            color:
                                Color(0xFF9699A8),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      Text(
                        _formatDuration(
                          totalDuration,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    child: Divider(
                      color: Colors.white
                          .withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ),

                  // BASE RENTAL
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Base rental',
                          style: TextStyle(
                            color:
                                Color(0xFF9699A8),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      Text(
                        '₱$baseAmount.00',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ADDITIONAL CHARGES
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Additional charges',
                          style: TextStyle(
                            color:
                                Color(0xFF9699A8),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      Text(
                        '₱$additionalCharge.00',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // =========================================
            // FINAL BILL
            // =========================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF173033),
                    Color(0xFF20243A),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color:
                      const Color(0xFF80BCBD)
                          .withValues(
                    alpha: 0.18,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FINAL BILL',
                          style: TextStyle(
                            color:
                                Color(0xFF80D6D4),
                            fontSize: 10,
                            letterSpacing: 1.3,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Total ride amount',
                          style: TextStyle(
                            color:
                                Color(0xFF9699A8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '₱$finalAmount.00',
                    style: const TextStyle(
                      color: Color(0xFFAAD9BB),
                      fontSize: 29,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =========================================
            // SAFETY NOTE
            // =========================================

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF17292B),
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color:
                      const Color(0xFF80BCBD)
                          .withValues(
                    alpha: 0.15,
                  ),
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFFAAD9BB),
                    size: 21,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Confirm the return only after the bicycle is safely parked at the rental station.',
                      style: TextStyle(
                        color:
                            Color(0xFFC6C8D1),
                        fontSize: 12,
                        height: 1.4,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================================
            // CONFIRM RETURN BUTTON
            // =========================================

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onDone,
                icon: const Icon(
                  Icons.lock_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Confirm Bicycle Return',
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFAAD9BB),
                  foregroundColor:
                      const Color(0xFF171827),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(28),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 11),

            const Center(
              child: Text(
                'Your ride will be marked as completed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9699A8),
                  fontSize: 11,
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// RETURN STEP
// ============================================================

class _ReturnStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _ReturnStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFAAD9BB),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF171827),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF9699A8),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Rentals extends StatelessWidget {
  final VoidCallback onActive;

  const Rentals({
    super.key,
    required this.onActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0D18),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          28,
          20,
          30,
        ),
        children: [
          // ==========================================
          // HEADER
          // ==========================================

          const Text(
            'Your rides',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Track your active ride and revisit previous adventures.',
            style: TextStyle(
              color: Color(0xFF9699A8),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 22),

          // ==========================================
          // ACTIVE RENTAL CARD
          // ==========================================

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onActive,
              borderRadius: BorderRadius.circular(26),
              child: Ink(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF173033),
                      Color(0xFF20243A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: const Color(0xFF80BCBD)
                        .withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ACTIVE BADGE + ARROW
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF24433C),
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 7,
                                color:
                                    Color(0xFFAAD9BB),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'ACTIVE RIDE',
                                style: TextStyle(
                                  color:
                                      Color(0xFFAAD9BB),
                                  fontSize: 9,
                                  letterSpacing: 0.7,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 27,
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // CURRENT RENTAL
                    const Row(
                      children: [
                        Icon(
                          Icons.pedal_bike_rounded,
                          color: Color(0xFF80D6D4),
                          size: 33,
                        ),

                        SizedBox(width: 13),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current rental',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap to view your live ride',
                                style: TextStyle(
                                  color:
                                      Color(0xFFB7BAC6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 19),

                    // STATUS / LOCATION
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.07,
                        ),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          // STATUS
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color:
                                      Color(0xFFAAD9BB),
                                  size: 19,
                                ),

                                SizedBox(width: 8),

                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      'Status',
                                      style: TextStyle(
                                        color: Color(
                                          0xFF9699A8,
                                        ),
                                        fontSize: 9,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'In progress',
                                      style: TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight
                                                .w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // LOCATION
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .location_on_outlined,
                                  color:
                                      Color(0xFFAAD9BB),
                                  size: 19,
                                ),

                                SizedBox(width: 8),

                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      'Location',
                                      style: TextStyle(
                                        color: Color(
                                          0xFF9699A8,
                                        ),
                                        fontSize: 9,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Azuela Cove',
                                      style: TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight
                                                .w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ==========================================
          // RIDE HISTORY HEADER
          // ==========================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ride history',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D2E),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF80D6D4),
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Text(
            'Your recently completed rentals.',
            style: TextStyle(
              color: Color(0xFF9699A8),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          // ==========================================
          // NORMAL BIKE HISTORY
          // ==========================================

          const _DarkRideHistoryCard(
            bikeName: 'Normal Bike',
            bikeId: 'N-118',
            date: 'August 8, 2026',
            duration: '1 hr 20 min',
            price: '₱120.00',
            iconColor: Color(0xFF80D6D4),
          ),

          const SizedBox(height: 12),

          // ==========================================
          // KIDS BIKE HISTORY
          // ==========================================

          const _DarkRideHistoryCard(
            bikeName: 'Kids Bike',
            bikeId: 'K-001',
            date: 'August 1, 2026',
            duration: '30 min',
            price: '₱30.00',
            iconColor: Color(0xFFAAD9BB),
          ),

          const SizedBox(height: 18),

          // ==========================================
          // INFO CARD
          // ==========================================

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF17292B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.15),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFFAAD9BB),
                  size: 22,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Completed rides and payment records will appear here.',
                    style: TextStyle(
                      color: Color(0xFFC6C8D1),
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkRideHistoryCard extends StatelessWidget {
  final String bikeName;
  final String bikeId;
  final String date;
  final String duration;
  final String price;
  final Color iconColor;

  const _DarkRideHistoryCard({
    required this.bikeName,
    required this.bikeId,
    required this.date,
    required this.duration,
    required this.price,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Row(
        children: [
          // BIKE ICON
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF252A3D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.pedal_bike_rounded,
              color: iconColor,
              size: 27,
            ),
          ),

          const SizedBox(width: 13),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  bikeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$bikeId • $date',
                  style: const TextStyle(
                    color: Color(0xFF9699A8),
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF80D6D4),
                      size: 14,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      duration,
                      style: const TextStyle(
                        color: Color(0xFF9699A8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // STATUS / PRICE
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF16312C),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFAAD9BB),
                      size: 12,
                    ),

                    SizedBox(width: 4),

                    Text(
                      'Completed',
                      style: TextStyle(
                        color: Color(0xFFAAD9BB),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFFAAD9BB),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _RentalStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RentalStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: secondary,
          size: 18,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class RentalHistoryCard extends StatelessWidget {
  final String bikeName;
  final String bikeId;
  final String date;
  final String duration;
  final String amount;

  const RentalHistoryCard({
    super.key,
    required this.bikeName,
    required this.bikeId,
    required this.date,
    required this.duration,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10214645),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F5F3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.pedal_bike_rounded,
              color: ink,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bikeName,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F5E8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF2E7D32),
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  '$bikeId • $date',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: muted,
                      size: 14,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      duration,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      amount,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class Alerts extends StatelessWidget {
  const Alerts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0D18),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          28,
          20,
          30,
        ),
        children: [
          // =====================================
          // HEADER
          // =====================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ride updates',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Important updates about your rides and account.',
                      style: TextStyle(
                        color: Color(0xFF9699A8),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF292D43),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFAAD9BB),
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // =====================================
          // ALL CAUGHT UP
          // =====================================

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF17292B),
                  Color(0xFF20243A),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16312C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFFAAD9BB),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 13),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You’re all caught up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'No urgent alerts right now.',
                        style: TextStyle(
                          color: Color(0xFF9699A8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // =====================================
          // RECENT
          // =====================================

          const Text(
            'Recent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 14),

          // RESERVATION
          const _DarkAlertCard(
            icon: Icons.check_rounded,
            title: 'Reservation confirmed',
            message:
                'K-001 is reserved and ready for your ride.',
            time: 'Just now',
            tag: 'Reservation',
            type: _AlertType.success,
          ),

          const SizedBox(height: 11),

          // PAYMENT
          const _DarkAlertCard(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Payment successful',
            message:
                'Your ₱30.00 payment has been confirmed.',
            time: '2 min ago',
            tag: 'Payment',
            type: _AlertType.payment,
          ),

          const SizedBox(height: 11),

          // RENTAL ENDING
          const _DarkAlertCard(
            icon: Icons.schedule_rounded,
            title: 'Rental ending soon',
            message:
                'Your rental will end in 5 minutes.',
            time: '10 min ago',
            tag: 'Reminder',
            type: _AlertType.reminder,
          ),

          const SizedBox(height: 11),

          // ZONE WARNING
          const _DarkAlertCard(
            icon: Icons.warning_rounded,
            title: 'Outside allowed zone',
            message:
                'The bicycle has left the designated riding area. Please return inside the red boundary.',
            time: 'Demo alert',
            tag: 'Zone warning',
            type: _AlertType.danger,
          ),

          const SizedBox(height: 11),

          // ID VERIFIED
          const _DarkAlertCard(
            icon: Icons.verified_user_rounded,
            title: 'ID verification approved',
            message:
                'Your rider account is now verified and ready to rent.',
            time: 'Yesterday',
            tag: 'Account',
            type: _AlertType.success,
          ),

          const SizedBox(height: 15),

          // =====================================
          // FOOTER INFO
          // =====================================

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF17292B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.14),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF80D6D4),
                  size: 21,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Rental, payment, safety, and account updates will appear here.',
                    style: TextStyle(
                      color: Color(0xFFC6C8D1),
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _AlertType {
  success,
  payment,
  reminder,
  danger,
}

class _DarkAlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final String tag;
  final _AlertType type;

  const _DarkAlertCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.tag,
    required this.type,
  });

  Color get accentColor {
    switch (type) {
      case _AlertType.success:
        return const Color(0xFFAAD9BB);

      case _AlertType.payment:
        return const Color(0xFF80D6D4);

      case _AlertType.reminder:
        return const Color(0xFFF9D77E);

      case _AlertType.danger:
        return const Color(0xFFFF6B6B);
    }
  }

  Color get iconBackground {
    switch (type) {
      case _AlertType.success:
        return const Color(0xFF16312C);

      case _AlertType.payment:
        return const Color(0xFF183238);

      case _AlertType.reminder:
        return const Color(0xFF3B321E);

      case _AlertType.danger:
        return const Color(0xFF3A171D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDanger = type == _AlertType.danger;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDanger
            ? const Color(0xFF25141A)
            : const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDanger
              ? const Color(0xFFFF6B6B)
                  .withValues(alpha: 0.50)
              : Colors.white.withValues(
                  alpha: 0.06,
                ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          // CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isDanger
                              ? const Color(
                                  0xFFFF7D7D,
                                )
                              : Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF777B8E),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  message,
                  style: TextStyle(
                    color: isDanger
                        ? const Color(
                            0xFFD7B5B9,
                          )
                        : const Color(
                            0xFF9699A8,
                          ),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PedalyaAlertCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String message;
  final String time;
  final String status;
  final bool important;

  const PedalyaAlertCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.message,
    required this.time,
    required this.status,
    this.important = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: important
            ? Border.all(
                color: Colors.red.withValues(alpha: 0.35),
              )
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x10214645),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: important ? Colors.red : ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    Text(
                      time,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  message,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class Profile extends StatelessWidget {
  final VoidCallback onLogout;

  const Profile({
    super.key,
    required this.onLogout,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0D18),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          28,
          20,
          30,
        ),
        children: [
          // =========================================
          // HEADER
          // =========================================

          const Text(
            'Your profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Manage your rider information and account.',
            style: TextStyle(
              color: Color(0xFF9699A8),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 26),

          // =========================================
          // PROFILE HERO CARD
          // =========================================

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF173033),
                  Color(0xFF20243A),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              children: [
                // AVATAR
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFF292D43),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFAAD9BB),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: Color(0xFFAAD9BB),
                      ),
                    ),

                    Positioned(
                      right: -2,
                      bottom: 2,
                      child: Container(
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          color: const Color(0xFFAAD9BB),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF20243A),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF171827),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                const Text(
                  'Alex Rider',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Pedalya Rider',
                  style: TextStyle(
                    color: Color(0xFF9699A8),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16312C),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Color(0xFFAAD9BB),
                        size: 14,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'VERIFIED RIDER',
                        style: TextStyle(
                          color: Color(0xFFAAD9BB),
                          fontSize: 9,
                          letterSpacing: 0.7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 27),

          // =========================================
          // PERSONAL INFORMATION
          // =========================================

          const Text(
            'Personal information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
            child: const Column(
              children: [
                _DarkProfileDetail(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: 'alex.rider@email.com',
                ),

                _ProfileDivider(),

                _DarkProfileDetail(
                  icon: Icons.phone_outlined,
                  label: 'Mobile number',
                  value: '+63 912 345 6789',
                ),

                _ProfileDivider(),

                _DarkProfileDetail(
                  icon: Icons.badge_outlined,
                  label: 'ID verification',
                  value: 'Valid ID verified',
                  verified: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 27),

          // =========================================
          // ACCOUNT
          // =========================================

          const Text(
            'Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
            child: Column(
              children: [
                _ProfileMenuItem(
                  icon: Icons.edit_outlined,
                  title: 'Edit profile',
                  subtitle: 'Update your personal details',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Edit profile will be connected later.',
                        ),
                      ),
                    );
                  },
                ),

                const _ProfileDivider(),

                _ProfileMenuItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change password',
                  subtitle: 'Keep your account secure',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Change password will be connected later.',
                        ),
                      ),
                    );
                  },
                ),

                const _ProfileDivider(),

                _ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & support',
                  subtitle: 'Get help with your Pedalya account',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Help and support will be connected later.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =========================================
          // SECURITY INFO
          // =========================================

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF17292B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.15),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFAAD9BB),
                  size: 21,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Your verified identity helps keep bicycle rentals safe and secure.',
                    style: TextStyle(
                      color: Color(0xFFC6C8D1),
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // =========================================
          // LOG OUT - VISUAL ONLY FOR NOW
          // =========================================

         SizedBox(
  width: double.infinity,
  height: 52,
  child: OutlinedButton.icon(
    onPressed: onLogout,
    icon: const Icon(
      Icons.logout_rounded,
      size: 18,
    ),
   label: const Text(
  'Log Out',
),
style: OutlinedButton.styleFrom(
  foregroundColor: const Color(0xFFFF7D7D),
  side: BorderSide(
    color: const Color(0xFFFF6B6B)
        .withValues(alpha: 0.45),
  ),
  backgroundColor: const Color(0xFF25141A),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(17),
  ),
  textStyle: const TextStyle(
    fontWeight: FontWeight.w900,
  ),
),
              ), // closes OutlinedButton.icon
            ),   // closes SizedBox
          ],     // closes ListView children
        ),       // closes ListView
      );         // closes Container / return
  }
}

class _DarkProfileDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool verified;

  const _DarkProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
    this.verified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF292D43),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF80D6D4),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9699A8),
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    color: verified
                        ? const Color(0xFFAAD9BB)
                        : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          if (verified)
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFAAD9BB),
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF292D43),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF80D6D4),
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9699A8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF777B8E),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 15,
      endIndent: 15,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F5F1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: ink,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: muted,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class Logo extends StatelessWidget { const Logo({super.key}); @override Widget build(BuildContext context) => const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.pedal_bike_rounded, color: ink, size: 31), SizedBox(width: 7), Text('pedalya', style: TextStyle(fontSize: 26, color: ink, fontWeight: FontWeight.w800))]); }
class Heading extends StatelessWidget { final String title; final String subtitle; const Heading({super.key, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink)), const SizedBox(height: 6), Text(subtitle, style: const TextStyle(color: muted, height: 1.35))]); }
class Label extends StatelessWidget { final String text; const Label(this.text, {super.key}); @override Widget build(BuildContext context) => Text(text.toUpperCase(), style: const TextStyle(color: muted, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w800)); }
class Input extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;

  const Input({
    super.key,
    required this.label,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(
          color: ink,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(
            icon,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class MainButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const MainButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: ink,
          elevation: 0,
          shadowColor: Colors.transparent,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),

          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],

            Text(label),
          ],
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const OutlineButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: Colors.white,

          side: const BorderSide(
            color: primary,
            width: 1.5,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),

          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 19,
              ),
              const SizedBox(width: 8),
            ],

            Text(label),
          ],
        ),
      ),
    );
  }
}

class CardBox extends StatelessWidget { final Widget child; const CardBox({super.key, required this.child}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x14214645), blurRadius: 10, offset: Offset(0, 4))]), child: child); }
class Detail extends StatelessWidget { final String label; final String value; final bool strong; const Detail({super.key, required this.label, required this.value, this.strong = false}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(label, style: TextStyle(color: strong ? ink : muted, fontWeight: strong ? FontWeight.w800 : FontWeight.w400))), Text(value, style: TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: strong ? 17 : 14))])); }
class Info extends StatelessWidget { final String text; const Info({super.key, required this.text}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.info_outline_rounded, color: ink), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: ink, height: 1.35)))])); }
class History extends StatelessWidget { final String date; final String bike; final String amount; const History({super.key, required this.date, required this.bike, required this.amount}); @override Widget build(BuildContext context) => CardBox(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(date, style: const TextStyle(color: ink, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('$bike  |  1 hr 20 min', style: const TextStyle(color: muted)), const SizedBox(height: 5), Text('$amount  Paid', style: const TextStyle(color: ink, fontWeight: FontWeight.w800))])); }
class Alert extends StatelessWidget { final IconData icon; final String title; final String text; const Alert({super.key, required this.icon, required this.title, required this.text}); @override Widget build(BuildContext context) => ListTile(leading: CircleAvatar(backgroundColor: accent, child: Icon(icon, color: ink)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: ink)), subtitle: Text(text), contentPadding: const EdgeInsets.symmetric(vertical: 6)); }
