import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  const Header(
      {super.key,
      required this.title,
      this.fontSize,
      this.color,
      this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Title(
      color: Colors.black,
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize ?? 20.0,
          color: color ?? const Color(0xFF505050),
          fontWeight: fontWeight ?? FontWeight.bold,
        ),
      ),
    );
  }
}
