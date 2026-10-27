import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/mascots.dart';
import '../../../data/models/account_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../../l10n/l10n_labels.dart';
import '../../view_models/parents/child_info_view_model.dart';
import '../../view_models/parents/parent_view_model.dart';
import '../../view_models/parents/update_settings_view_model.dart';
import '../../widgets/shared/top_banner.dart';
import '../../widgets/update_settings/inline_error.dart';
import '../../widgets/update_settings/update_btn_settings.dart';
import '../../widgets/update_settings/update_header_settings.dart';

class UpdateMascotView extends StatefulWidget {
  const UpdateMascotView({super.key});

  @override
  State<UpdateMascotView> createState() => _UpdateMascotViewState();
}

class _UpdateMascotViewState extends State<UpdateMascotView> {
  late String _selected = context.read<ChildInfoViewModel>().mascotId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UpdateSettingsViewModel>().clearError();
    });
  }

  Future<void> _submit() async {
    final childInfo = context.read<ChildInfoViewModel>();
    final navigator = Navigator.of(context);

    final updateVM = context.read<UpdateSettingsViewModel>();
    final parentVM = context.read<ParentViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);

    final result = await updateVM.updateMascot(childId: parentVM.currentChildId, mascotId: _selected);

    if (result is! AccountSuccess) return;
    childInfo.applyMascot(result.value ?? _selected);
    TopBanner.show(overlay, l10n.appMessage(result.message, detail: result.value));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final updateVM = context.watch<UpdateSettingsViewModel>();
    final l10n = AppLocalizations.of(context);
    final changed = _selected != context.watch<ChildInfoViewModel>().mascotId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UpdateHeaderSettings(title: l10n.mascot),
              Text(
                l10n.mascotIntro,
                style: const TextStyle(color: AppColors.slideBubble, fontSize: 14, fontFamily: AppAssets.fontFamily),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.9,
                children: [for (final mascot in Mascots.all) _card(mascot, l10n.mascotLabel(mascot.id))],
              ),
              const SizedBox(height: 30),
              UpdateBtnSettings(
                text: l10n.updateMascot,
                isBusy: updateVM.isLoading,
                enabled: changed,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              InlineError(message: updateVM.error),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(MascotOption mascot, String label) {
    final selected = mascot.id == _selected;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: () => setState(() => _selected = mascot.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? AppColors.btnSave.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.btnSave : const Color(0xFFE0E0E0),
              width: selected ? 3 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Expanded(child: Image.asset(mascot.asset, fit: BoxFit.contain)),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppAssets.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: selected ? AppColors.btnSave : AppColors.darkPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
