import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';

class ParentHeader extends StatelessWidget {
  const ParentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Image.asset(
              AppAssets.iconSettingsHeart,
              width: 35,
              height: 35,
            ),
            onPressed: (){},
          ),
        ],
      ),
    );
  }
}