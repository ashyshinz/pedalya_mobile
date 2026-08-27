import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart'; 
import 'models/bike_variant.dart';
import 'screens/bikes/bike_details_screen.dart';
import 'screens/rental/reservation_screen.dart';
import 'screens/rental/payment_screen.dart';
import 'screens/rental/active_ride_screen.dart';
import 'screens/rental/return_bike_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

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
String get riderName =>
    ApiService.currentUser?['name']?.toString() ??
    'Rider';

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

Future<void> startRental() async {
  final bike = selectedBike;

  if (bike == null || bike.databaseId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This bicycle is missing its database ID.',
        ),
      ),
    );
    return;
  }

  int durationMinutes = 30;

  final durationText =
      selectedDuration.toLowerCase();

  final match =
      RegExp(r'\d+').firstMatch(durationText);

  final number = match == null
      ? null
      : int.tryParse(match.group(0)!);

  if (number != null) {
    if (durationText.contains('hour')) {
      durationMinutes = number * 60;
    } else if (durationText.contains('minute')) {
      durationMinutes = number;
    }
  }

  final result = await ApiService.startRental(
    bike.databaseId!,
    durationMinutes,
  );

  if (!mounted) return;

  if (result['success'] != true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ??
              'Failed to start rental.',
        ),
      ),
    );
    return;
  }

  await openActiveRentalFromApi();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        result['message']?.toString() ??
            'Rental started successfully.',
      ),
    ),
  );
}

Future<void> openActiveRentalFromApi() async {
  final response = await ApiService.getActiveRentals();

  if (!mounted) return;

  if (response['success'] != true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response['message']?.toString() ??
              'Failed to load active rental.',
        ),
      ),
    );
    return;
  }

  final rawRentals = response['rentals'];

  if (rawRentals is! List || rawRentals.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'You do not have an active rental.',
        ),
      ),
    );
    return;
  }

  final firstRental = rawRentals.first;

  if (firstRental is! Map) {
    return;
  }

  final rental =
      Map<String, dynamic>.from(firstRental);

  final parsedStartTime = DateTime.tryParse(
    rental['startTime']?.toString() ?? '',
  );

  final parsedExpectedEndTime = DateTime.tryParse(
    rental['expectedEndTime']?.toString() ?? '',
  );

  int durationMinutes = 30;

  if (parsedStartTime != null &&
      parsedExpectedEndTime != null) {
    durationMinutes = parsedExpectedEndTime
        .difference(parsedStartTime)
        .inMinutes;
  }

  String durationLabel;

  if (durationMinutes == 60) {
    durationLabel = '1 hour';
  } else if (durationMinutes == 120) {
    durationLabel = '2 hours';
  } else {
    durationLabel = '$durationMinutes minutes';
  }

  final hourlyRate = double.tryParse(
        rental['ratePerHour']?.toString() ?? '',
      ) ??
      0;

  final bicycleDatabaseId = int.tryParse(
    rental['bicycleId']?.toString() ?? '',
  );

  setState(() {
    selectedBike = BikeVariantData(
      databaseId: bicycleDatabaseId,
      variant: BikeVariant.standard,
      name:
          rental['bicycleName']?.toString() ??
          'Bicycle',
      id:
          rental['bicycleSerial']?.toString() ??
          rental['rentalId']?.toString() ??
          'Bike',
      range: 'Active rental',
      price:
          '₱${hourlyRate.toStringAsFixed(2)} / hour',
      accentColor: const Color(0xFFE5F7F0),
      bodyColor: const Color(0xFF6BC7C9),
      imagePath: 'assets/images/normal_bike.jpg',
    );

    rentalStartTime =
        parsedStartTime?.toLocal() ??
        DateTime.now();

    selectedDuration = durationLabel;

    selectedEstimatedCost =
        hourlyRate.round();

    extended = false;
    stage = 'active';
  });
}

Future<void> completeActiveRental() async {
  final activeResponse =
      await ApiService.getActiveRentals();

  if (!mounted) return;

  if (activeResponse['success'] != true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          activeResponse['message']?.toString() ??
              'Failed to load active rental.',
        ),
      ),
    );
    return;
  }

  final rawRentals =
      activeResponse['rentals'];

  if (rawRentals is! List ||
      rawRentals.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No active or overdue rental found.',
        ),
      ),
    );
    return;
  }

  final rawRental = rawRentals.first;

  if (rawRental is! Map) {
    return;
  }

  final rental =
      Map<String, dynamic>.from(rawRental);

  final rentalId = int.tryParse(
    rental['id']?.toString() ?? '',
  );

  if (rentalId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Rental ID is unavailable.',
        ),
      ),
    );
    return;
  }

  double? returnLat;
  double? returnLng;

  final rawBicycle = rental['bicycle'];

  if (rawBicycle is Map) {
    returnLat = double.tryParse(
      rawBicycle['currentLat']
              ?.toString() ??
          '',
    );

    returnLng = double.tryParse(
      rawBicycle['currentLng']
              ?.toString() ??
          '',
    );
  }

  final result =
      await ApiService.returnRental(
    rentalId,
    returnLat: returnLat,
    returnLng: returnLng,
    notes:
        'Returned through Pedalya mobile app',
  );

  if (!mounted) return;

  if (result['success'] == true) {
    setState(() {
      stage = 'dashboard';
      tab = 2;

      selectedBike = null;
      rentalStartTime = null;
      extended = false;
      selectedDuration = '30 minutes';
      selectedEstimatedCost = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ??
              'Bicycle returned successfully.',
        ),
      ),
    );

    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        result['message']?.toString() ??
            'Failed to return bicycle.',
      ),
    ),
  );
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
    onDone: completeActiveRental,
  );

  } else {
    body = Dashboard(
      tab: tab,
      onTab: (value) => setState(() => tab = value),
      onBike: openBike,
      onActive: openActiveRentalFromApi,
      onLogout: () => open('welcome'),
    );
  }

  return body;
}
}
