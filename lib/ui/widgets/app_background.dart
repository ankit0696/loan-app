import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // Color(0xFFF2C94C),
            // Color(0xFFE7C440),
            // Color(0xFFD9B136),
            // Color(0xFFC9940E),
            Color(0xFFC9940E),
            Color(0xFFD9B136),
            Color(0xFFE7C440),
            Color(0xFFF2C94C),
          ],
        ),
      ),
      child: child,
    );
  }
}
