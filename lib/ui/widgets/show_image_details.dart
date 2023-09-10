import 'package:flutter/material.dart';

void showImageDialog(BuildContext context, String name, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // show image
            Image.network(imageUrl),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
