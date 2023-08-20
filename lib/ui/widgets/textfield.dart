import 'package:flutter/material.dart';

import 'header.dart';

Widget textField(
    {String? label,
    String? hint,
    IconData? icon,
    bool? isPassword,
    bool? disabled,
    BuildContext? context,
    TextInputType? keyboardType,
    Function()? onIconTap,
    Function()? onTap,
    String? Function(String?)? validator,
    TextEditingController? controller}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      label != null ? Header(title: label, fontSize: 15.0) : const SizedBox(),
      const SizedBox(height: 10.0),
      Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF9F6609),
            width: 1.0,
          ),
          color: const Color(0x19FFC107),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                onTap: onTap ?? () {},
                validator: validator ??
                    (value) {
                      return null;
                    },
                keyboardType: keyboardType ?? TextInputType.text,
                enabled: disabled ?? true,
                obscureText: isPassword ?? false,
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 254, 254, 254),
                      fontSize: 15.0),
                  border: InputBorder.none,
                ),
              ),
            ),
            InkWell(
              onTap: onIconTap ?? () {},
              child: Icon(icon, color: const Color(0xFF646363)),
            ),
          ],
        ),
      ),
    ],
  );
}
