import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import 'package:provider/provider.dart';
import '../../view_models/navbar_view_model.dart';
import 'category_selector.dart';

class CreateStoryHeader extends StatelessWidget {
  const CreateStoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 30,
        top: MediaQuery.of(context).padding.top + 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.read<NavbarViewModel>().changeIndex(0);
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 6),
              child: Icon(Icons.arrow_back, color: AppColors.darkPurple, size: 28),
            ),
          ),

          const Text(
            "I want a story about...",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: AppAssets.fontFamily,
              color: AppColors.darkPurple,
            ),
          ),
          const SizedBox(height: 20),
          const CategorySelector(),
        ],
      ),
    );
  }
}