import 'package:flutter/material.dart';

import 'package:pedalya_mobile/models/bike_variant.dart';
import 'package:pedalya_mobile/screens/home/home_screen.dart';
import 'package:pedalya_mobile/screens/bikes/bikes_screen.dart';
import 'package:pedalya_mobile/screens/rental/rentals_screen.dart';
import 'package:pedalya_mobile/screens/alerts/alerts_screen.dart';
import 'package:pedalya_mobile/screens/profile/profile_screen.dart';


class Dashboard extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  final ValueChanged<BikeVariantData> onBike;
  final VoidCallback onActive;
  final VoidCallback onLogout;
 const Dashboard({
  super.key,
  required this.tab,
  required this.onTab,
  required this.onBike,
  required this.onActive,
  required this.onLogout,
});


  @override
  Widget build(BuildContext context) {
final pages = [
  Home(
    onBike: onBike,
    onActive: onActive,
    onTab: onTab,
  ),
  Bikes(onBike: onBike),
  Rentals(onActive: onActive),
  const Alerts(),
  Profile(onLogout: onLogout),
];

    return Scaffold(
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: pages[tab]))),
bottomNavigationBar: Container(
  color: const Color(0xFF0B0D18),
  padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
  child: SafeArea(
    top: false,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181B2C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: NavigationBar(
          height: 68,
          selectedIndex: tab,
          onDestinationSelected: onTab,

          backgroundColor: const Color(0xFF181B2C),

          indicatorColor: const Color(0xFFAAD9BB),

          elevation: 0,

          labelBehavior:
              NavigationDestinationLabelBehavior.alwaysShow,

          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: Color(0xFF8F93A3),
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: Color(0xFF172323),
                size: 23,
              ),
              label: 'Home',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.pedal_bike_outlined,
                color: Color(0xFF8F93A3),
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.pedal_bike_rounded,
                color: Color(0xFF172323),
                size: 23,
              ),
              label: 'Bikes',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.route_outlined,
                color: Color(0xFF8F93A3),
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.route_rounded,
                color: Color(0xFF172323),
                size: 23,
              ),
              label: 'Rentals',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF8F93A3),
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.notifications_rounded,
                color: Color(0xFF172323),
                size: 23,
              ),
              label: 'Alerts',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF8F93A3),
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: Color(0xFF172323),
                size: 23,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    ),
  ),
),
    );
  }
}