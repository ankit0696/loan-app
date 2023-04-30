import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  final double? fontSize;
  final Color? color;
  const Header({super.key, required this.title, this.fontSize, this.color});

  @override
  Widget build(BuildContext context) {
    return Title(
      color: Colors.black,
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize ?? 20.0,
          color: color ?? const Color.fromARGB(255, 137, 136, 136),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
