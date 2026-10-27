import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../l10n/app_localizations.dart';

class ChildInfoHeader extends StatelessWidget{
  const ChildInfoHeader ({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
              Icons.arrow_back,
              color: Colors.white
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 16),
        Text(
          l10n.childInfoTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
      ],
    );
  }
}