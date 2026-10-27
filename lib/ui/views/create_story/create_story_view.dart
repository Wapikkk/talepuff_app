import 'package:flutter/material.dart';
import '../../../core/story_defaults.dart';
import '../../view_models/create_story/create_story_view_model.dart';
import '../../widgets/create_story/create_story_header.dart';
import '../../widgets/create_story/choice_chip_group.dart';
import '../../widgets/create_story/generate_button.dart';
import '../../widgets/create_story/section_tittle.dart';
import '../../widgets/create_story/custom_input_field.dart';
import '../../widgets/app_background.dart';
import '../../widgets/stars_overlay.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/l10n/app_localizations.dart';
import 'package:talepuff_app/l10n/app_message_text.dart';
import 'package:talepuff_app/l10n/l10n_labels.dart';

class CreateStoryView extends StatelessWidget {
  const CreateStoryView({super.key});

  static String Function(StoryField) _fieldLabel(AppLocalizations l10n) => (field) => switch (field) {
        StoryField.category => l10n.fieldCategory,
        StoryField.length => l10n.fieldLength,
        StoryField.voice => l10n.fieldVoice,
      };

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateStoryViewModel>();
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        body: AppBackground(
          child: Stack(
            children: [
              const StarsOverlay(),
              SafeArea(
                top: false,
                bottom: false,
                child: SingleChildScrollView(
                  key: ValueKey(viewModel.formVersion),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CreateStoryHeader(),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle(title: l10n.createCharacterName),
                            CustomInputField(
                              hint: l10n.createNicknameHint,
                              onChanged: (value) {
                                context
                                    .read<CreateStoryViewModel>()
                                    .setCharacterName(value);
                              },
                            ),
                            if (viewModel.nameError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  l10n.appMessage(viewModel.nameError!),
                                  key: const Key('name-error'),
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                ),
                              ),

                            SectionTitle(title: l10n.createStoryLength),
                            ChoiceChipGroup(
                              options: const ['3', '5', '7'],
                              labelOf: l10n.lengthLabel,
                              onSelected: (value) {
                                context
                                    .read<CreateStoryViewModel>()
                                    .setStoryLength(value);
                              },
                            ),

                            SectionTitle(title: l10n.createMood),
                            ChoiceChipGroup(
                              labelOf: l10n.moodLabel,
                              options: [
                                'Calm',
                                'Curious',
                                'Warm',
                                'Joyful',
                                'Fantasy',
                                'Cozy',
                                'Brave',
                                'Nature',
                              ],
                              onSelected: (value) {
                                context.read<CreateStoryViewModel>().toggleMood(
                                  value,
                                );
                              },
                            ),

                            SectionTitle(title: l10n.createVoice),
                            ChoiceChipGroup(
                              options: StoryDefaults.voices,
                              labelOf: l10n.voiceLabel,
                              onSelected: (value) {
                                context.read<CreateStoryViewModel>().setVoiceTone(value);
                              },
                            ),

                            SectionTitle(title: l10n.createDescribe),
                            CustomInputField(
                              hint: l10n.createDescribeHint,
                              maxLines: 4,
                              onChanged: (value) {
                                context
                                    .read<CreateStoryViewModel>()
                                    .setDescription(value);
                              },
                            ),

                            if (viewModel.error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  l10n.appMessage(
                                    viewModel.error!,
                                    detail: viewModel.missingFields().map(_fieldLabel(l10n)).join(', '),
                                  ),
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                ),
                              ),

                            GenerateButton(
                              onPressed: viewModel.isLoading
                                  ? () {}
                                  : () {
                                      context
                                          .read<CreateStoryViewModel>()
                                          .generateStory(context);
                                    },
                            ),

                            if (viewModel.isLoading)
                              const Center(child: CircularProgressIndicator()),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
