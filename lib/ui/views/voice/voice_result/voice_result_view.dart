import 'package:flutter/material.dart';
import '../../..//widgets/app_background.dart';
import '../../../views/voice/voice_selection_dialog/voice_selection_dialog_view.dart';
import '../../../views/loading_screen/loading_screen_view.dart';
import '../../../widgets/voice/voice_result/voice_image_header.dart';
import '../../../widgets/voice/voice_result/voice_text_content.dart';
import '../../../widgets/voice/voice_result/re_generate_button.dart';

class VoiceResultView extends StatefulWidget{
  final String title;
  final String generatedText;
  final String imageUrl;
  final Map<String, dynamic> payload;

  const VoiceResultView ({
    super.key,
    required this.title,
    required this.generatedText,
    required this.imageUrl,
    required this.payload
  });

  @override
  State<VoiceResultView> createState() => _VoiceResultViewState();
}

class _VoiceResultViewState extends State<VoiceResultView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoiceSelectionDialogView.show(context);
    });
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
                          imageUrl: widget.imageUrl,
                          onBackPressed: () => Navigator.pop(context),
                          onFavoritePressed: () {},
                        ),
                        const SizedBox(height: 30),

                        VoiceTextContent(
                          text: widget.title,
                          title: widget.generatedText,
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  
                  ReGenerateButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoadingScreenView(
                            payload: widget.payload,
                          ),
                        ),
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