import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/widgets/cloud_overlay.dart';
import '../../../ui/widgets/stars_overlay.dart';
import '../../../ui/widgets/app_background.dart';
import '../../../ui/view_models/loading/loading_view_model.dart';
import '../../../ui/widgets/loading_screen/loading_header.dart';
import '../../../ui/widgets/loading_screen/loading_mascot_slider.dart';
import '../../../ui/widgets/loading_screen/loading_progress.dart';
import '../../../ui/widgets/loading_screen/loading_text.dart';

class LoadingScreenView extends StatefulWidget{
  final Map<String, dynamic> payload;

  const LoadingScreenView({super.key, required this.payload});

  @override
  State<LoadingScreenView> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoadingViewModel>().startGeneratingStory(context, widget.payload);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: [
            const StarsOverlay(),
            const CloudOverlay(),

            SafeArea(
              child: Column(
                children: const [
                  LoadingHeader(),
                  SizedBox(height: 40),
                  LoadingText(),
                  SizedBox(height: 20),
                  LoadingMascotSlider(),
                  SizedBox(height: 20),
                  LoadingProgress(),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
