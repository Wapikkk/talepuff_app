import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/validators.dart';
import '../../../data/models/account_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../../l10n/l10n_labels.dart';
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

  static const _categories = ['bug', 'idea', 'other'];

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
    final l10n = AppLocalizations.of(context);

    final result = await viewModel.send(_messageController.text);

    if (result is! AccountSuccess) return;
    TopBanner.show(overlay, l10n.appMessage(result.message, detail: result.value));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeedbackViewModel>();
    final l10n = AppLocalizations.of(context);

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
                UpdateHeaderSettings(title: l10n.sendFeedback),
                const SizedBox(height: 4),
                Text(
                  l10n.feedbackIntro,
                  style: const TextStyle(color: AppColors.slideBubble, fontSize: 14, fontFamily: AppAssets.fontFamily),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children: [
                    for (final category in _categories)
                      ChoiceChip(
                        label: Text(l10n.feedbackCategoryLabel(category)),
                        selected: viewModel.category == category,
                        onSelected: (_) => viewModel.selectCategory(category),
                        selectedColor: AppColors.btnSave,
                        labelStyle: TextStyle(
                          fontFamily: AppAssets.fontFamily,
                          fontWeight: FontWeight.bold,
                          color: viewModel.category == category ? Colors.white : AppColors.darkPurple,
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
                    hintText: l10n.feedbackHint,
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
                  text: l10n.send,
                  isBusy: viewModel.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                InlineError(message: viewModel.error),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
