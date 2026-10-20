import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';

class InlineError extends StatelessWidget {
  final String? message;
  const InlineError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: message != null ? 1.0 : 0.0,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          message ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
      ),
    );
  }
}
