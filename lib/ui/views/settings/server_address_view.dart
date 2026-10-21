import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/server_address.dart';
import '../../../data/services/server_check_service.dart';
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

  static String _display(String url) => url.replaceFirst(RegExp(r'^https?://'), '');

  Future<void> _test() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final overlay = TopBanner.overlayOf(context);
    final reachable = await _viewModel.check(_controller.text);
    if (reachable != null) TopBanner.show(overlay, 'Connected to the server');
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final overlay = TopBanner.overlayOf(context);
    final navigator = Navigator.of(context);
    final outcome = await _viewModel.save(_controller.text);
    if (outcome != ServerSaveOutcome.saved) return;
    TopBanner.show(overlay, 'Server address saved');
    navigator.pop(true);
  }

  Future<void> _useDefault() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final overlay = TopBanner.overlayOf(context);
    final navigator = Navigator.of(context);
    await _viewModel.useDefault();
    TopBanner.show(overlay, 'Back to the built-in address');
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Consumer<ServerAddressViewModel>(
              builder: (context, viewModel, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UpdateHeaderSettings(title: 'Server Address'),
                  const SizedBox(height: 20),
                  UpdateInputSettings(
                    label: 'Server address',
                    hint: '192.168.1.5:8080',
                    controller: _controller,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Use your computer's address on the same Wi-Fi. On the computer, run ipconfig and look for the IPv4 address.",
                    style: TextStyle(
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
                        side: const BorderSide(color: AppColors.btnSave, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: viewModel.isChecking ? null : _test,
                      child: viewModel.isChecking
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.btnSave),
                            )
                          : const Text(
                              'Test connection',
                              style: TextStyle(
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
                    text: 'Save',
                    enabled: !viewModel.isChecking,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 12),
                  InlineError(message: viewModel.errorMessage),
                  if (ServerAddress.isCustom)
                    Center(
                      child: TextButton(
                        key: const Key('use-default'),
                        onPressed: _useDefault,
                        child: const Text(
                          'Use the built-in address',
                          style: TextStyle(color: AppColors.slideBubble, fontFamily: AppAssets.fontFamily),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
