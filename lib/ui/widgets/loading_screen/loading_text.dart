import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/app_assets.dart';
import '../../view_models/loading/loading_view_model.dart';
import 'package:talepuff_app/l10n/app_localizations.dart';
import 'package:talepuff_app/l10n/l10n_labels.dart';

class LoadingText extends StatelessWidget {
  const LoadingText({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoadingViewModel>();
    final label = AppLocalizations.of(context).loadingStageLabel(viewModel.stage);

    return SizedBox(
      height: 40,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: AppAssets.fontFamily,
          color: Colors.white,
        ),
        child: viewModel.isWorking
            ? AnimatedTextKit(
                key: ValueKey(viewModel.stage),
                repeatForever: true,
                isRepeatingAnimation: true,
                animatedTexts: [
                  TypewriterAnimatedText(
                    label,
                    speed: const Duration(milliseconds: 90),
                    cursor: '',
                  ),
                ],
              )
            : Text(label),
      ),
    );
  }
}
