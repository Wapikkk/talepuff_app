import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/account_result.dart';
import '../data/models/app_message.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_message_text.dart';
import 'view_models/totem/totem_view_model.dart';
import 'widgets/shared/top_banner.dart';

class TotemFlow {
  TotemFlow._();

  static Future<void> playStory(BuildContext context, int storyId, {String? title}) async {
    final totem = context.read<TotemViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);

    if (!totem.isLoaded) await totem.refresh();
    if (!totem.isPaired) {
      TopBanner.show(overlay, l10n.appMessage(AppMessage.totemNotPaired), type: TopBannerType.info);
      navigator.pushNamed('/totem');
      return;
    }
    final result = await totem.play(storyId);
    if (result is AccountFailure) {
      TopBanner.show(overlay, l10n.appMessage(result.message), type: TopBannerType.error);
    } else if (result is AccountSuccess && title != null) {
      TopBanner.show(overlay, l10n.playingOnTotem(title));
    }
  }
}
