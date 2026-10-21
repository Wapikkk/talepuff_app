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

class CreateStoryView extends StatelessWidget {
  const CreateStoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateStoryViewModel>();
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
                            const SectionTitle(title: "Character Name"),
                            CustomInputField(
                              hint: "Custom Your Nickname",
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
                                  viewModel.nameError!,
                                  key: const Key('name-error'),
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                ),
                              ),

                            const SectionTitle(title: "Story Length"),
                            ChoiceChipGroup(
                              options: const [
                                '3 Minutes',
                                '5 Minutes',
                                '7 Minutes',
                              ],
                              onSelected: (value) {
                                context
                                    .read<CreateStoryViewModel>()
                                    .setStoryLength(value);
                              },
                            ),

                            const SectionTitle(title: "Mood"),
                            ChoiceChipGroup(
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

                            const SectionTitle(title: "Voice"),
                            ChoiceChipGroup(
                              options: StoryDefaults.voices,
                              onSelected: (value) {
                                context.read<CreateStoryViewModel>().setVoiceTone(value);
                              },
                            ),

                            const SectionTitle(title: "Describe Your Story"),
                            CustomInputField(
                              hint: "Optional, max 30 words. English or Indonesian is fine.",
                              maxLines: 4,
                              onChanged: (value) {
                                context
                                    .read<CreateStoryViewModel>()
                                    .setDescription(value);
                              },
                            ),

                            if (viewModel.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  viewModel.errorMessage!,
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
