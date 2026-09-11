import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';

class VoiceDialogContainer extends StatelessWidget{
  final String title;
  final Widget child;

  const VoiceDialogContainer({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2541),
                fontFamily: AppAssets.fontFamily,
              ),
            ),
            const SizedBox(height: 24),

            // Konten (Grid tombol dan tombol Done) akan di-render di sini
            child,
          ],
        ),
      ),
    );
  }
}