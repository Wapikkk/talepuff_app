import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/account_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../../l10n/l10n_labels.dart';
import '../../view_models/totem/totem_view_model.dart';
import '../../widgets/shared/dismiss_keyboard.dart';
import '../../widgets/shared/top_banner.dart';
import '../../widgets/update_settings/update_btn_settings.dart';
import '../../widgets/update_settings/update_header_settings.dart';
import '../../widgets/update_settings/update_input_settings.dart';

class TotemView extends StatefulWidget {
  const TotemView({super.key});

  @override
  State<TotemView> createState() => _TotemViewState();
}

class _TotemViewState extends State<TotemView> {
  final _controller = TextEditingController();
  late final TotemViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<TotemViewModel>()..watch();
  }

  @override
  void dispose() {
    _viewModel.unwatch();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run(Future<AccountResult?> Function() action) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);
    final result = await action();
    switch (result) {
      case AccountSuccess():
        _controller.clear();
        TopBanner.show(overlay, l10n.appMessage(result.message));
      case AccountFailure():
        TopBanner.show(overlay, l10n.appMessage(result.message), type: TopBannerType.error);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = context.watch<TotemViewModel>();

    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UpdateHeaderSettings(title: l10n.totem),
                const SizedBox(height: 10),
                if (!viewModel.isLoaded && viewModel.error == null)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (viewModel.isPaired)
                  _paired(l10n, viewModel)
                else
                  _unpaired(l10n, viewModel),
                if (viewModel.error != null && !viewModel.isLoaded) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.appMessage(viewModel.error!),
                    key: const Key('totem-error'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontFamily: AppAssets.fontFamily),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _unpaired(AppLocalizations l10n, TotemViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.totemLinkIntro,
          style: const TextStyle(color: AppColors.slideBubble, fontSize: 14, fontFamily: AppAssets.fontFamily),
        ),
        const SizedBox(height: 20),
        UpdateInputSettings(label: l10n.totemId, hint: 'totem-001', controller: _controller),
        const SizedBox(height: 30),
        UpdateBtnSettings(
          text: l10n.totemLink,
          isBusy: viewModel.isBusy,
          onPressed: () => _run(() => viewModel.pair(_controller.text)),
        ),
      ],
    );
  }

  Widget _paired(AppLocalizations l10n, TotemViewModel viewModel) {
    final status = viewModel.status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.dividerLine,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.speaker, color: status.online ? AppColors.btnSave : Colors.grey, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totemLinkedTo(viewModel.deviceId ?? ''),
                      key: const Key('totem-device'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.darkPurple,
                        fontFamily: AppAssets.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.totemStateLabel(status),
                      key: const Key('totem-state'),
                      style: TextStyle(
                        fontSize: 14,
                        color: status.online ? AppColors.darkPurple : Colors.grey,
                        fontFamily: AppAssets.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        UpdateBtnSettings(
          text: l10n.totemUnlink,
          isBusy: viewModel.isBusy,
          onPressed: () => _run(viewModel.unpair),
        ),
      ],
    );
  }
}
