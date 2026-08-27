import 'dart:async';
import 'package:pedalya_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import 'package:pedalya_mobile/models/bike_variant.dart';
import 'package:pedalya_mobile/core/theme/app_colors.dart';
import 'package:pedalya_mobile/widgets/common/app_page.dart';


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
  _loadBikeLocationFromApi();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _updateTimer();
      },
    );
  }

  Future<void> _loadBikeLocationFromApi() async {
  final response = await ApiService.getActiveRentals();

  if (!mounted) return;

  if (response['success'] != true) {
    return;
  }

  final rawRentals = response['rentals'];

  if (rawRentals is! List || rawRentals.isEmpty) {
    return;
  }

  final firstRental = rawRentals.first;

  if (firstRental is! Map) {
    return;
  }

  final rental =
      Map<String, dynamic>.from(firstRental);

  double? lat;
  double? lng;

  // Prefer the bicycle's CURRENT GPS position.
  final rawBicycle = rental['bicycle'];

  if (rawBicycle is Map) {
    lat = double.tryParse(
      rawBicycle['currentLat']?.toString() ?? '',
    );

    lng = double.tryParse(
      rawBicycle['currentLng']?.toString() ?? '',
    );
  }

  // Fallback to the rental's start location.
  if (lat == null || lng == null) {
    final rawLocation = rental['startLocation'];

    if (rawLocation is Map) {
      lat = double.tryParse(
        rawLocation['lat']?.toString() ?? '',
      );

      lng = double.tryParse(
        rawLocation['lng']?.toString() ?? '',
      );
    }
  }

  if (lat == null || lng == null) {
    return;
  }

  setState(() {
    bikeLocation = LatLng(lat!, lng!);
  });
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

  bool get isRentalOverdue {
  return elapsed >= totalDuration;
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
                          horizontal: 8,
                          vertical: 6,
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
                              size: 7,
                              color: isOutsideZone
                                  ? const Color(
                                      0xFFFF6464,
                                    )
                                  : const Color(
                                      0xFFAAD9BB,
                                    ),
                            ),

                            const SizedBox(width: 5),

                            Text(
                                isOutsideZone
                               ? 'OUTSIDE ZONE'
                                : isRentalOverdue
                                   ? 'OVERDUE'
                                     : 'ACTIVE',
                               style: TextStyle(
                                color: isOutsideZone
                                    ? const Color(
                                        0xFFFF7D7D,
                                      )
                                    : const Color(
                                        0xFFAAD9BB,
                                      ),
                                fontSize: 9,
                                letterSpacing: 0.3,
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