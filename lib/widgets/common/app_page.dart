import 'package:flutter/material.dart';
import 'package:pedalya_mobile/core/theme/app_colors.dart';

class AppPage extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;
  const AppPage({super.key, required this.child, this.onBack});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Stack(
                children: [
                  child,
                  if (onBack != null)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_rounded, color: ink),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}
