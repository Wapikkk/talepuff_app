import 'package:flutter/material.dart';
import '../../view_models/create_story/create_story_view_model.dart';
import '../../widgets/create_story/create_story_header.dart';
import '../../widgets/create_story/choice_chip_group.dart';
import '../../widgets/create_story/generate_button.dart';
import '../../widgets/create_story/section_tittle.dart';
import '../../widgets/create_story/custom_input_field.dart';
import '../../widgets/app_background.dart';
import '../../widgets/stars_overlay.dart';
import 'package:provider/provider.dart';

class CreateStoryView extends StatelessWidget{
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CreateStoryHeader(),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionTitle(title: "Character Name"),
                            CustomInputField(
                              hint: "Custom Your Nickname",
                              onChanged: (value) {
                                context.read<CreateStoryViewModel>().setCharacterName(value);
                              },
                            ),

                            const SectionTitle(title: "Story Length"),
                            ChoiceChipGroup(
                              options: const ['3 Minutes', '5 Minutes', '7 Minutes'],
                              onSelected: (value) {
                                context.read<CreateStoryViewModel>().setStoryLength(value);
                              },
                            ),

                            const SectionTitle(title: "Mood"),
                            ChoiceChipGroup(
                              options: [
                                'Calm', 'Curious', 'Warm', 'Joyful',
                                'Fantasy', 'Cozy', 'Brave', 'Nature'
                              ],
                              onSelected: (value) {
                                context.read<CreateStoryViewModel>().toggleMood(value);
                              },
                            ),

                            const SectionTitle(title: "Language"),
                            ChoiceChipGroup(
                              options: ['Basic English', 'Mixed (EN + ID)'],
                              onSelected: (value) {
                                context.read<CreateStoryViewModel>().setLanguage(value);
                              },
                            ),

                            const SectionTitle(title: "Describe Your Story"),
                            CustomInputField(
                              hint: "Optional, max 30 words",
                              maxLines: 4,
                              onChanged: (value) {
                                context.read<CreateStoryViewModel>().setDescription(value);
                              },
                            ),

                            GenerateButton(
                              onPressed: viewModel.isLoading
                                  ? () {}
                                  : () {
                                context.read<CreateStoryViewModel>().generateStory(context);
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