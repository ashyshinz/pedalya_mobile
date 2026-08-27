import 'package:flutter/material.dart';
import 'package:pedalya_mobile/models/bike_variant.dart';
import 'package:pedalya_mobile/widgets/common/app_page.dart';
import 'package:pedalya_mobile/core/theme/app_colors.dart';
import 'package:pedalya_mobile/widgets/common/main_button.dart';

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
                  color: mutedText,
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
                  color: mutedText,
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
                          color: mutedText,
                          size: 14,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Azuela Cove',
                          style: TextStyle(
                            color: mutedText,
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
            color: mutedText,
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
