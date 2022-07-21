import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

void displayResponsiveMotionToast(dynamic context, String text, String description) {
    MotionToast(
    icon: Icons.rocket_launch,
    primaryColor: Colors.deepOrange,
    title: Text(
        text,
        style: const TextStyle(
        fontWeight: FontWeight.bold,
        ),
    ),
    description: Text(
        description,
    ),
    animationDuration: const Duration(milliseconds: 2500),
    ).show(context);
}