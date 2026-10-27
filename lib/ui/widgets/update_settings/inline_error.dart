import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../data/models/app_message.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';

class InlineError extends StatelessWidget {
  final AppMessage? message;
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
          message == null ? '' : AppLocalizations.of(context).appMessage(message!),
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
