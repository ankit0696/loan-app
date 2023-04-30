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
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label != null ? Header(title: label, fontSize: 15.0) : const SizedBox(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
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
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15.0,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              InkWell(
                onTap: onIconTap ?? () {},
                child: Icon(
                  icon,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
