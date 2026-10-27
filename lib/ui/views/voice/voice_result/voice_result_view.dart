import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/account_result.dart';
import '../../../../data/models/story.dart';
import '../../../../data/repositories/story_repository.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/shared/top_banner.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/app_message_text.dart';
import '../../loading_screen/loading_screen_view.dart';
import '../../../widgets/voice/voice_result/voice_image_header.dart';
import '../../../widgets/voice/voice_result/voice_text_content.dart';
import '../../../widgets/voice/voice_result/re_generate_button.dart';

class VoiceResultView extends StatefulWidget {
  final StoryDetail story;
  final Map<String, dynamic> payload;

  const VoiceResultView({super.key, required this.story, required this.payload});

  @override
  State<VoiceResultView> createState() => _VoiceResultViewState();
}

class _VoiceResultViewState extends State<VoiceResultView> {
  late bool _isFavorite = widget.story.isFavorite;
  bool _saving = false;

  Future<void> _toggleFavorite() async {
    if (_saving) return;
    final repository = context.read<StoryRepository>();
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);
    final wanted = !_isFavorite;

    setState(() {
      _isFavorite = wanted;
      _saving = true;
    });
    final result = await repository.setFavorite(widget.story.id, wanted);
    if (!mounted) return;

    setState(() {
      _saving = false;
      if (result is AccountFailure) _isFavorite = !wanted;
    });
    if (result is AccountFailure) {
      TopBanner.show(overlay, l10n.appMessage(result.message), type: TopBannerType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VoiceImageHeader(
                          theme: widget.story.theme,
                          isFavorite: _isFavorite,
                          onBackPressed: () => Navigator.pop(context),
                          onFavoritePressed: _toggleFavorite,
                        ),
                        const SizedBox(height: 30),
                        VoiceTextContent(title: widget.story.title, text: widget.story.content),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  ReGenerateButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoadingScreenView(payload: widget.payload)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
