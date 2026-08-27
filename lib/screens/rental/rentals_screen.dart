import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pedalya_mobile/core/theme/app_colors.dart';
import 'package:pedalya_mobile/services/api_service.dart';

class Rentals extends StatefulWidget {
  final VoidCallback onActive;

  const Rentals({
    super.key,
    required this.onActive,
  });

  @override
  State<Rentals> createState() => _RentalsState();
}

class _RentalsState extends State<Rentals> {
  List<Map<String, dynamic>> activeRentals = [];
  List<Map<String, dynamic>> completedRentals = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final activeResponse =
        await ApiService.getActiveRentals();

    final completedResponse =
        await ApiService.getCompletedRentals();

    if (!mounted) return;

    if (activeResponse['success'] == true &&
        completedResponse['success'] == true) {
      final rawActive = activeResponse['rentals'];
      final rawCompleted = completedResponse['rentals'];

      setState(() {
        activeRentals =
            rawActive is List
                ? rawActive
                    .whereType<Map>()
                    .map(
                      (item) =>
                          Map<String, dynamic>.from(item),
                    )
                    .toList()
                : [];

        completedRentals =
            rawCompleted is List
                ? rawCompleted
                    .whereType<Map>()
                    .map(
                      (item) =>
                          Map<String, dynamic>.from(item),
                    )
                    .toList()
                : [];

        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage =
            activeResponse['message']?.toString() ??
            completedResponse['message']?.toString() ??
            'Failed to load rentals.';

        isLoading = false;
      });
    }
  }
String _formatRentalLocation(dynamic value) {
  if (value == null) {
    return 'Location unavailable';
  }

  // Laravel may already return the location as a Map.
  if (value is Map) {
    final lat =
        double.tryParse(value['lat']?.toString() ?? '');

    final lng =
        double.tryParse(value['lng']?.toString() ?? '');

    if (lat != null && lng != null) {
      return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    }
  }

  final raw = value.toString().trim();

  if (raw.isEmpty) {
    return 'Location unavailable';
  }

  // Fallback in case Laravel returns a JSON string.
  try {
    final decoded = jsonDecode(raw);

    if (decoded is Map) {
      final lat =
          double.tryParse(decoded['lat']?.toString() ?? '');

      final lng =
          double.tryParse(decoded['lng']?.toString() ?? '');

      if (lat != null && lng != null) {
        return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      }
    }
  } catch (_) {}

  return raw;
}
  

  @override
  Widget build(BuildContext context) {
    final activeRental =
    activeRentals.isNotEmpty ? activeRentals.first : null;
    final activeStatus =
    activeRental?['status']?.toString() ?? '';

final activeStatusLabel =
    activeStatus.isEmpty
        ? 'In progress'
        : '${activeStatus[0].toUpperCase()}${activeStatus.substring(1)}';

final activeLocation =
    _formatRentalLocation(
      activeRental?['startLocation'],
    );

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

          if (activeRentals.isNotEmpty)
           Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onActive,
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
                  Row(
  children: [
    const Icon(
      Icons.pedal_bike_rounded,
      color: Color(0xFF80D6D4),
      size: 33,
    ),
    const SizedBox(width: 13),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activeRental?['bicycleName']?.toString() ??
                'Current rental',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            activeRental?['bicycleSerial']?.toString() ??
                activeRental?['rentalId']?.toString() ??
                'Active ride',
            style: const TextStyle(
              color: Color(0xFFB7BAC6),
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
                    // STATUS / LOCATION
Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white.withValues(
      alpha: 0.07,
    ),
    borderRadius: BorderRadius.circular(18),
  ),
  child: Row(
    children: [
      // STATUS
      Expanded(
        child: Row(
          children: [
            const Icon(
              Icons.timer_outlined,
              color: Color(0xFFAAD9BB),
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      color: Color(0xFF9699A8),
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeStatusLabel,
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
        ),
      ),

      const SizedBox(width: 12),

      // LOCATION
      Expanded(
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Color(0xFFAAD9BB),
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: Color(0xFF9699A8),
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
  activeLocation,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.w800,
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
            ),
          ),
        ),

if (activeRentals.isEmpty && !isLoading)
  Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1D2E),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.06),
      ),
    ),
    child: const Row(
      children: [
        Icon(
          Icons.pedal_bike_outlined,
          color: Color(0xFF80D6D4),
          size: 30,
        ),
        SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No active ride',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your current rental will appear here once a ride starts.',
                style: TextStyle(
                  color: Color(0xFF9699A8),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
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

         if (isLoading)
  const Padding(
    padding: EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: CircularProgressIndicator(
        color: Color(0xFF80BCBD),
      ),
    ),
  )
else if (errorMessage != null)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      children: [
        Text(
          errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9699A8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _loadRentals,
          child: const Text('Try again'),
        ),
      ],
    ),
  )
else if (completedRentals.isEmpty)
  const Padding(
    padding: EdgeInsets.symmetric(vertical: 22),
    child: Center(
      child: Text(
        'No completed rides yet.',
        style: TextStyle(
          color: Color(0xFF9699A8),
          fontSize: 12,
        ),
      ),
    ),
  )
else
  ...completedRentals.asMap().entries.expand((entry) {
    final index = entry.key;
    final rental = entry.value;

    return [
      _DarkRideHistoryCard(
        bikeName:
            rental['bicycleName']?.toString() ??
            'Bicycle',
        bikeId:
            rental['bicycleSerial']?.toString() ??
            rental['rentalId']?.toString() ??
            'Unknown',
        date: _formatRentalDate(
          rental['startTime'],
        ),
        duration:
            rental['durationFormatted']?.toString() ??
            '${rental['durationMinutes'] ?? 0} min',
        price: _formatRentalPrice(
          rental['totalFee'],
        ),
        iconColor: const Color(0xFF80D6D4),
      ),
      if (index < completedRentals.length - 1)
        const SizedBox(height: 12),
    ];
  }),

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
 String _formatRentalDate(dynamic value) {
  if (value == null) return 'Unknown date';

  final parsed = DateTime.tryParse(value.toString());

  if (parsed == null) return 'Unknown date';

  final date =
      parsed.isUtc
          ? parsed.add(const Duration(hours: 8))
          : parsed;

  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _formatRentalPrice(dynamic value) {
  if (value == null) return '₱0.00';

  final amount = double.tryParse(value.toString()) ?? 0;

  return '₱${amount.toStringAsFixed(2)}';
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

