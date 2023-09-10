import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> customSnackbar({
  required String message,
  required BuildContext context,
  Color? color,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
          child: Text(message, style: const TextStyle(color: Colors.black))),
      duration: const Duration(seconds: 2),
      backgroundColor: color ?? Colors.grey[300],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    ),
  );
}
