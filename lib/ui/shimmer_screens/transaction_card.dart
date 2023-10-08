import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TransactionCardShimmer extends StatelessWidget {
  const TransactionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      gradient: LinearGradient(colors: [
        Colors.grey[300]!, // Lighter color
        Colors.grey, // Slightly darker color
        Colors.grey[300]!, // Lighter color (same as the first one)
      ]),
      child: Container(
        height: 100.0, // Adjust the height as needed
        width: double.infinity, // Takes the full width available
        margin: const EdgeInsets.all(10.0), // Optional margin
      ),
    );
  }
}
