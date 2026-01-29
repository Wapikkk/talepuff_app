import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_colors.dart';
import '../../../ui/view_models/parent_view_model.dart';
import '../../../core/app_assets.dart';

class ChildProfilePhoto extends StatelessWidget {
  const ChildProfilePhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ParentViewModel>(
      builder: (context, parentVM, child) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 64,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: parentVM.imagePreview != null
                      ? FileImage(parentVM.imagePreview!) as ImageProvider
                      : (parentVM.currentPhotoUrl != null
                          ? NetworkImage("http://172.19.202.227:8080${parentVM.currentPhotoUrl}")
                          : const AssetImage(AppAssets.mascotHarimauSumatera)),
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                _showPickerMenu(context, parentVM);
              },
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.listCreate1,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    AppAssets.iconStylus,
                    color: Colors.white,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPickerMenu(BuildContext context, ParentViewModel parentVM) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.listCreate1,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkPurple,
                fontFamily: AppAssets.fontFamily,
              ),
            ),
            const SizedBox(height: 15),

            ListTile(
              leading: Image.asset(AppAssets.iconAddAPhoto),
              title: const Text(
                'Camera',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppAssets.fontFamily,
                  color: AppColors.darkPurple,
                ),
              ),
              onTap: () {
                parentVM.handleImageSelection(ImageSource.camera);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Image.asset(AppAssets.iconEditAPhoto),
              title: const Text(
                'Choose from library',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppAssets.fontFamily,
                  color: AppColors.darkPurple,
                ),
              ),
              onTap: () {
                parentVM.handleImageSelection(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),

            if(parentVM.imagePreview != null)
              ListTile(
                leading: Image.asset(AppAssets.iconRemovePhoto),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppAssets.fontFamily,
                    color: AppColors.storiesCount,
                  ),
                ),
                onTap: () {
                  parentVM.removePhoto();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}