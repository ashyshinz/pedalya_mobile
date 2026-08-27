import 'package:flutter/material.dart';
import 'package:pedalya_mobile/models/bike_variant.dart';
import 'package:pedalya_mobile/widgets/common/app_page.dart';

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
