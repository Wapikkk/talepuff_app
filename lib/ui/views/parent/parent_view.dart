import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/parents/child_info_view_model.dart';
import '../../view_models/auth/login_view_model.dart';
import '../../../ui/widgets/app_background.dart';
import '../../../ui/widgets/stars_overlay.dart';
import '../../../ui/widgets/cloud_overlay.dart';
import '../../../ui/widgets/parent/child_profile_info.dart';
import '../../../ui/widgets/parent/parent_header.dart';
import '../../../ui/widgets/parent/child_profile_photo.dart';

class ParentView extends StatelessWidget {
  const ParentView ({super.key});

  @override
  Widget build(BuildContext context) {
    final childVM = context.watch<ChildInfoViewModel>();
    final loginVM = context.watch<LoginViewModel>();
    final screenHeight = MediaQuery.of(context).size.height;
    const double photoRadius = 60.0;
    const double topBackgroundHeight = 220.0;

    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: [
            const StarsOverlay(),
            const CloudOverlay(),

            SingleChildScrollView(
              child: Stack(
                alignment: Alignment.topCenter,
                children:[
                  Container(
                    margin: const EdgeInsets.only(top: topBackgroundHeight),
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: screenHeight - topBackgroundHeight,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: photoRadius + 15),
                          ChildProfileInfo(
                            name: childVM.childName,
                            age: childVM.age,
                            email: loginVM.email,
                            interests: childVM.selectedInterests,
                          ),

                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: topBackgroundHeight - photoRadius,
                    child: const ChildProfilePhoto(),
                  ),

                  const SafeArea(child: ParentHeader()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}