import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color? buttonColor;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
    this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            buttonColor ?? const Color(0xFFB47D0A),
            buttonColor ?? const Color(0xFF915D0E),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF9F6609),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: TextStyle(
            color: buttonColor != null ? Colors.black : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
