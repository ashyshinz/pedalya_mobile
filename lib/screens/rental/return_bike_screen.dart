import 'package:flutter/material.dart';
import 'package:pedalya_mobile/widgets/common/app_page.dart';
import 'package:pedalya_mobile/models/bike_variant.dart';


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