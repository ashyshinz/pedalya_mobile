import 'package:flutter/material.dart';

enum BikeVariant {
  kids,
  doubleBike,
  standard,
}

class BikeVariantData {
  final BikeVariant variant;
  final String name;
  final String id;
  final int? databaseId;
  final String range;
  final String price;
  final Color accentColor;
  final Color bodyColor;
  final String imagePath;

  const BikeVariantData({
    required this.variant,
    required this.name,
    required this.id,
    this.databaseId,
    required this.range,
    required this.price,
    required this.accentColor,
    required this.bodyColor,
    required this.imagePath,
  });
}