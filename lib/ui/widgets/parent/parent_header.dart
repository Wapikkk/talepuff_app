import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/view_models/navbar_view_model.dart';
import '../../../core/app_assets.dart';
import '../../views/settings/settings_view.dart';

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
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              context.read<NavbarViewModel>().changeIndex(0);
            },
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Image.asset(
              AppAssets.iconSettingsHeart,
              width: 35,
              height: 35,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsView()));
            },
          ),
        ],
      ),
    );
  }
}