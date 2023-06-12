import 'package:flutter/material.dart';
import 'package:loan_app/ui/widgets/custom_button.dart';

class ContentBox extends StatelessWidget {
  final String heading;
  final String content;
  final VoidCallback onPressed;
  final String? buttonText;

  const ContentBox({
    Key? key,
    required this.heading,
    required this.content,
    required this.onPressed,
    this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.shortestSide * 0.8,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(onPressed: onPressed, buttonText: buttonText ?? "Next"),
        ],
      ),
    );
  }
}
