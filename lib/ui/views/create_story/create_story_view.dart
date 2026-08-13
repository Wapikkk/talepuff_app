import 'package:flutter/material.dart';
import '../../view_models/create_story_view_model.dart';
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
    return Scaffold(
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
                          const ChoiceChipGroup(
                            options: ['3 Minutes', '5 Minutes', '7 Minutes'],
                          ),

                          const SectionTitle(title: "Mood"),
                          const ChoiceChipGroup(
                            options: [
                              'Calm', 'Curious', 'Warm', 'Joyful',
                              'Fantasy', 'Cozy', 'Brave', 'Nature'
                            ],
                          ),

                          const SectionTitle(title: "Language"),
                          const ChoiceChipGroup(
                            options: ['Basic English', 'Mixed (EN + ID)'],
                          ),

                          const SectionTitle(title: "Describe Your Story"),
                          const CustomInputField(
                            hint: "Optional, max 30 words",
                            maxLines: 4,
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
    );
  }
}