import '../../widgets/shared/dismiss_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/server_address.dart';
import '../../../data/services/server_check_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../view_models/settings/server_address_view_model.dart';
import '../../widgets/shared/top_banner.dart';
import '../../widgets/update_settings/inline_error.dart';
import '../../widgets/update_settings/update_btn_settings.dart';
import '../../widgets/update_settings/update_header_settings.dart';
import '../../widgets/update_settings/update_input_settings.dart';

class ServerAddressView extends StatefulWidget {
  const ServerAddressView({super.key});

  @override
  State<ServerAddressView> createState() => _ServerAddressViewState();
}

class _ServerAddressViewState extends State<ServerAddressView> {
  late final ServerAddressViewModel _viewModel;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _viewModel = ServerAddressViewModel(checker: context.read<ServerChecker>());
    _controller = TextEditingController(text: _display(ServerAddress.baseUrl));
  }

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  static String _display(String url) =>
      url.replaceFirst(RegExp(r'^https?://'), '');

  Future<void> _test() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);
    final reachable = await _viewModel.check(_controller.text);
    if (reachable != null) TopBanner.show(overlay, l10n.serverConnected);
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final overlay = TopBanner.overlayOf(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final outcome = await _viewModel.save(_controller.text);
    if (outcome != ServerSaveOutcome.saved) return;
    TopBanner.show(overlay, l10n.serverSaved);
    navigator.pop(true);
  }

  Future<void> _useDefault() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final overlay = TopBanner.overlayOf(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    await _viewModel.useDefault();
    TopBanner.show(overlay, l10n.serverBackToDefault);
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: DismissKeyboard(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Consumer<ServerAddressViewModel>(
                builder: (context, viewModel, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UpdateHeaderSettings(title: l10n.serverAddress),
                    const SizedBox(height: 20),
                    UpdateInputSettings(
                      label: l10n.serverAddressLabel,
                      hint: '192.168.1.5:8080',
                      controller: _controller,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.serverAddressHelp,
                      style: const TextStyle(
                        color: AppColors.slideBubble,
                        fontSize: 13,
                        fontFamily: AppAssets.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        key: const Key('test-connection'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.btnSave,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: viewModel.isChecking ? null : _test,
                        child: viewModel.isChecking
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.btnSave,
                                ),
                              )
                            : Text(
                                l10n.testConnection,
                                style: const TextStyle(
                                  color: AppColors.btnSave,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppAssets.fontFamily,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    UpdateBtnSettings(
                      text: l10n.save,
                      enabled: !viewModel.isChecking,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 12),
                    InlineError(message: viewModel.error),
                    if (ServerAddress.isCustom)
                      Center(
                        child: TextButton(
                          key: const Key('use-default'),
                          onPressed: _useDefault,
                          child: Text(
                            l10n.useBuiltInAddress,
                            style: const TextStyle(
                              color: AppColors.slideBubble,
                              fontFamily: AppAssets.fontFamily,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
