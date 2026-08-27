import 'package:flutter/material.dart';
import 'package:pedalya_mobile/models/bike_variant.dart';
import 'package:pedalya_mobile/services/api_service.dart';

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

  List<BikeVariantData> bikes = [];

  bool isLoading = true;
  String? loadError;

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
        isLoading = false;
        loadError =
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
      bikes = loadedBikes;
      isLoading = false;
      loadError = null;
    });
  }

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