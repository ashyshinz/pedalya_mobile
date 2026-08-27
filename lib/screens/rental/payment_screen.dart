import 'package:flutter/material.dart';
import 'package:pedalya_mobile/models/bike_variant.dart';
import 'package:pedalya_mobile/widgets/common/app_page.dart';

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