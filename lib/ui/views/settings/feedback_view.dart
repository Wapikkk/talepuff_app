import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/validators.dart';
import '../../../data/models/account_result.dart';
import '../../view_models/settings/feedback_view_model.dart';
import '../../widgets/shared/top_banner.dart';
import '../../widgets/update_settings/inline_error.dart';
import '../../widgets/update_settings/update_btn_settings.dart';
import '../../widgets/update_settings/update_header_settings.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final TextEditingController _messageController = TextEditingController();

  static const _categoryLabels = {'bug': 'Bug', 'idea': 'Idea', 'other': 'Other'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FeedbackViewModel>().reset();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final viewModel = context.read<FeedbackViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final navigator = Navigator.of(context);

    final result = await viewModel.send(_messageController.text);

    if (result is! AccountSuccess) return;
    TopBanner.show(overlay, result.message);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeedbackViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UpdateHeaderSettings(title: 'Send Feedback'),
                const SizedBox(height: 4),
                const Text(
                  'Tell us what is not working or what you would like to see.',
                  style: TextStyle(color: AppColors.slideBubble, fontSize: 14, fontFamily: AppAssets.fontFamily),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children: [
                    for (final entry in _categoryLabels.entries)
                      ChoiceChip(
                        label: Text(entry.value),
                        selected: viewModel.category == entry.key,
                        onSelected: (_) => viewModel.selectCategory(entry.key),
                        selectedColor: AppColors.btnSave,
                        labelStyle: TextStyle(
                          fontFamily: AppAssets.fontFamily,
                          fontWeight: FontWeight.bold,
                          color: viewModel.category == entry.key ? Colors.white : AppColors.darkPurple,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _messageController,
                  maxLines: 7,
                  minLines: 5,
                  maxLength: FeedbackValidators.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Write your message here...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                UpdateBtnSettings(
                  text: 'Send',
                  isBusy: viewModel.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                InlineError(message: viewModel.errorMessage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
