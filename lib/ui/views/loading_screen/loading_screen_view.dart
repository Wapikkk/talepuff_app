import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../ui/widgets/cloud_overlay.dart';
import '../../../ui/widgets/stars_overlay.dart';
import '../../../ui/widgets/app_background.dart';
import '../../../ui/view_models/loading/loading_view_model.dart';
import '../../../ui/widgets/loading_screen/loading_failure.dart';
import '../../../ui/widgets/loading_screen/loading_header.dart';
import '../../../ui/widgets/loading_screen/loading_mascot_slider.dart';
import '../../../ui/widgets/loading_screen/loading_progress.dart';
import '../../../ui/widgets/loading_screen/loading_text.dart';
import '../../../ui/widgets/shared/top_banner.dart';
import '../voice/voice_result/voice_result_view.dart';

class LoadingScreenView extends StatefulWidget {
  final Map<String, dynamic> payload;
  final VoidCallback? onCreated;

  const LoadingScreenView({super.key, required this.payload, this.onCreated});

  @override
  State<LoadingScreenView> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreenView> {
  late final LoadingViewModel _viewModel;
  OverlayState? _overlay;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _viewModel = LoadingViewModel(repository: context.read<StoryRepository>());
    _viewModel.addListener(_onChanged);
    _viewModel.start(widget.payload, onCreated: widget.onCreated);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _overlay = TopBanner.overlayOf(context);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_leaving || _viewModel.stage != LoadingStage.done || _viewModel.story == null) return;
    _leaving = true;

    final story = _viewModel.story!;
    final notice = _viewModel.notice;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final overlay = _overlay;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VoiceResultView(story: story, payload: widget.payload)),
      );
      if (notice != null && overlay != null) {
        TopBanner.show(overlay, notice, type: TopBannerType.info);
      }
    });
  }

  void _onPopped(bool didPop, Object? result) {
    final overlay = _overlay;
    if (didPop && !_leaving && _viewModel.isWorking && overlay != null) {
      TopBanner.show(
        overlay,
        "We'll keep working on it. Your story will appear in Story when it's ready.",
        type: TopBannerType.info,
      );
    }
  }

  void _openSavedStory() {
    final id = _viewModel.story?.id;
    if (id == null) return;
    _leaving = true;
    Navigator.pushReplacementNamed(context, '/story_detail', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: PopScope(
        onPopInvokedWithResult: _onPopped,
        child: Scaffold(
          body: AppBackground(
            child: Stack(
              children: [
                const StarsOverlay(),
                const CloudOverlay(),
                SafeArea(
                  child: Column(
                    children: [
                      const LoadingHeader(),
                      const SizedBox(height: 40),
                      const LoadingText(),
                      const SizedBox(height: 20),
                      const LoadingMascotSlider(),
                      const SizedBox(height: 20),
                      Consumer<LoadingViewModel>(builder: (context, viewModel, _) => _bottom(context, viewModel)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottom(BuildContext context, LoadingViewModel viewModel) {
    if (viewModel.stage != LoadingStage.failed) return const LoadingProgress();

    return LoadingFailure(
      message: viewModel.failureMessage ?? '',
      primaryLabel: viewModel.storyWasSaved ? 'Open story' : 'Try again',
      onPrimary: viewModel.storyWasSaved
          ? _openSavedStory
          : () => _viewModel.start(widget.payload, onCreated: widget.onCreated),
      secondaryLabel: 'Back',
      onSecondary: () => Navigator.pop(context),
    );
  }
}
