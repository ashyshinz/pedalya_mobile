import 'package:flutter/material.dart';
import 'package:pedalya_mobile/models/bike_variant.dart';
import 'package:pedalya_mobile/services/api_service.dart';

class Home extends StatefulWidget {
  final ValueChanged<BikeVariantData> onBike;
  final VoidCallback onActive;
  final ValueChanged<int> onTab;

  const Home({
    super.key,
    required this.onBike,
    required this.onActive,
    required this.onTab,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<BikeVariantData> availableBikes = [];

  bool isLoadingBikes = true;
  String? bikeLoadError;

  @override
  void initState() {
    super.initState();
    _loadAvailableBicycles();
  }

  BikeVariant _getBikeVariant(
    Map<String, dynamic> bicycle,
  ) {
    final text = [
      bicycle['name'],
      bicycle['model'],
      bicycle['description'],
    ].whereType<String>().join(' ').toLowerCase();

    if (text.contains('kid')) {
      return BikeVariant.kids;
    }

    if (text.contains('double') ||
        text.contains('tandem')) {
      return BikeVariant.doubleBike;
    }

    return BikeVariant.standard;
  }

  String _getBikeImage(BikeVariant variant) {
    switch (variant) {
      case BikeVariant.kids:
        return 'assets/images/kids_bike.jpg';

      case BikeVariant.doubleBike:
        return 'assets/images/double_bike.jpg';

      case BikeVariant.standard:
        return 'assets/images/normal_bike.jpg';
    }
  }

  Future<void> _loadAvailableBicycles() async {
    final result =
        await ApiService.getAvailableBicycles();

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        isLoadingBikes = false;
        bikeLoadError =
            result['message']?.toString() ??
            'Failed to load bicycles.';
      });
      return;
    }

    final rawBicycles = result['bicycles'];
    final loadedBikes = <BikeVariantData>[];

    if (rawBicycles is List) {
      for (final raw in rawBicycles) {
        if (raw is! Map) {
          continue;
        }

        final bicycle =
            Map<String, dynamic>.from(raw);

        final databaseId = int.tryParse(
          bicycle['id']?.toString() ?? '',
        );

        if (databaseId == null) {
          continue;
        }

        final variant =
            _getBikeVariant(bicycle);

        final hourlyRate = double.tryParse(
              bicycle['hourlyRate']
                      ?.toString() ??
                  '',
            ) ??
            0;

        final serialNumber =
            bicycle['serialNumber']
                    ?.toString() ??
                'BIKE-$databaseId';

        final name =
            bicycle['name']?.toString() ??
                'Pedalya Bicycle';

        final model =
            bicycle['model']
                    ?.toString()
                    .trim() ??
                '';

        final description =
            bicycle['description']
                    ?.toString()
                    .trim() ??
                '';

        String range = '1 rider';

        if (model.isNotEmpty) {
          range = model;
        } else if (description.isNotEmpty) {
          range = description;
        }

        Color accentColor;
        Color bodyColor;

        switch (variant) {
          case BikeVariant.kids:
            accentColor =
                const Color(0xFFBFEFE9);
            bodyColor =
                const Color(0xFF5EC9D4);
            break;

          case BikeVariant.doubleBike:
            accentColor =
                const Color(0xFFE3F4F1);
            bodyColor =
                const Color(0xFF7BCFCF);
            break;

          case BikeVariant.standard:
            accentColor =
                const Color(0xFFEAF8F4);
            bodyColor =
                const Color(0xFF5FC5C8);
            break;
        }

        loadedBikes.add(
          BikeVariantData(
            databaseId: databaseId,
            variant: variant,
            name: name,
            id: serialNumber,
            range: range,
            price:
                'PHP ${hourlyRate.toStringAsFixed(2)} / hour',
            accentColor: accentColor,
            bodyColor: bodyColor,
            imagePath:
                _getBikeImage(variant),
          ),
        );
      }
    }

    setState(() {
      availableBikes = loadedBikes;
      isLoadingBikes = false;
      bikeLoadError = null;
    });
  }

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
                            onTap: () => widget.onTab(4),
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
                        'Find a bike nearby and start exploring Azuela.',
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
                          onPressed: () => widget.onTab(1),
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
                     Expanded(
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
                           isLoadingBikes
                           ? 'Loading bicycles...'
                            : bikeLoadError != null
                             ? 'Could not load bicycles'
                              : '${availableBikes.length} bikes ready to ride',
                             style: const TextStyle(
                          color: Color(0xFF9396A6),
    fontSize: 12,
  ),
),
                        ],
                      ),
                    ),

                    TextButton(
                      onPressed: () => widget.onTab(1),
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

              if (isLoadingBikes)
  const Padding(
    padding: EdgeInsets.symmetric(
      vertical: 30,
    ),
    child: Center(
      child: CircularProgressIndicator(
        color: Color(0xFF80BCBD),
      ),
    ),
  )
else if (bikeLoadError != null)
  Center(
    child: TextButton.icon(
      onPressed: () {
        setState(() {
          isLoadingBikes = true;
          bikeLoadError = null;
        });

        _loadAvailableBicycles();
      },
      icon: const Icon(
        Icons.refresh_rounded,
      ),
      label: const Text(
        'Try Again',
      ),
    ),
  )
else if (availableBikes.isEmpty)
  const Padding(
    padding: EdgeInsets.symmetric(
      vertical: 24,
    ),
    child: Center(
      child: Text(
        'No bicycles available right now.',
        style: TextStyle(
          color: Color(0xFF9699A8),
          fontSize: 12,
        ),
      ),
    ),
  )
else
  ...availableBikes.take(3).map(
    (bike) => Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: _DarkHomeBikeCard(
        bike: bike,
        onTap: () {
          widget.onBike(bike);
        },
      ),
    ),
  ),

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
