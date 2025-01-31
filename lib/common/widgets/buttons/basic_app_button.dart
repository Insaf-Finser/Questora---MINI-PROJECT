// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:quest/core/config/theme/app_colors.dart';

class RoundAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double ? height;
  const RoundAppButton({
    required this.onPressed,
    required this.title,
    this.height,
    super.key, 
    
    });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(height ?? 60),
        shape: const CircleBorder(),
        backgroundColor:Colors.white.withOpacity(0.15),
        side: const BorderSide(color: AppColors.primary, width: 3),
      ),
      child: Text(title),
    );
  }
}