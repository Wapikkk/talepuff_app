import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '/core/app_colors.dart';
import '../../../data/models/account_result.dart';
import '../../../data/models/app_message.dart';
import '../../../data/repositories/profile_photo_repository.dart';

class ParentViewModel extends ChangeNotifier{
  ParentViewModel({required ProfilePhotoRepository photos}) : _photos = photos;

  final ProfilePhotoRepository _photos;

  File? _imagePreview; get imagePreview => _imagePreview;
  String? _currentChildId, _currentChildName, _currentPhotoUrl;
  String? get currentChildId => _currentChildId; get currentChildName => _currentChildName; get currentPhotoUrl => _currentPhotoUrl;
  bool _isUploading = false, _isAutoStoryEnabled = false;
  bool get isUploading => _isUploading; get isAutoStoryEnabled => _isAutoStoryEnabled;
  String _selectedHour = "08", _selectedMinute = "30";
  String get selectedHour => _selectedHour; get selectedMinute => _selectedMinute;
  bool _isAM = true; get isAM => _isAM;

  final ImagePicker _picker = ImagePicker();

  void setInitiateData(String? childId, String? photoUrl, String? name) {
    _currentChildId = childId;
    _currentChildName = name;
    _currentPhotoUrl = photoUrl;
    _imagePreview = null;
    notifyListeners();
  }

  void updateLocalChildName(String newName) {
    _currentChildName = newName;
    notifyListeners();
  }

  Future<AccountResult?> handleImageSelection(ImageSource source, String childId, {required String cropTitle}) async {
    if (_isUploading) return null;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (pickedFile == null) return null;

      final croppedFile = await _cropImage(pickedFile.path, cropTitle);
      if (croppedFile == null) return null;

      return uploadProfilePhoto(childId, File(croppedFile.path));
    } catch (e) {
      debugPrint("Error picking image: $e");
      return const AccountFailure(AppMessage.photoPickerFailed);
    }
  }

  Future<CroppedFile?> _cropImage(String path, String title) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: AppColors.darkPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: title,
          aspectRatioLockEnabled: true,
          cropStyle: CropStyle.circle,
        ),
      ],
    );
  }

  void clearPreview() {
    _imagePreview = null;
    notifyListeners();
  }

  Future<AccountResult?> uploadProfilePhoto(String childId, File file) async {
    final id = int.tryParse(childId);
    if (id == null) return const AccountFailure(AppMessage.childDataNotLoaded);
    if (_isUploading) return null;

    _imagePreview = file;
    _isUploading = true;
    notifyListeners();
    try {
      final result = await _photos.upload(childId: id, filePath: file.path);
      if (result is AccountSuccess) _currentPhotoUrl = result.value;
      return result;
    } finally {
      _imagePreview = null;
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<AccountResult?> removePhoto() async {
    final id = int.tryParse(_currentChildId ?? '');
    if (id == null) return const AccountFailure(AppMessage.childDataNotLoaded);
    if (_isUploading) return null;

    _isUploading = true;
    notifyListeners();
    try {
      final result = await _photos.remove(childId: id);
      if (result is AccountSuccess) {
        _imagePreview = null;
        _currentPhotoUrl = null;
      }
      return result;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void toggleAutoStory(bool value) {
    _isAutoStoryEnabled = value;
    notifyListeners();
  }

  void updateTime(String hour, String minute, bool am) {
    _selectedHour = hour;
    _selectedMinute = minute;
    _isAM = am;
    notifyListeners();
  }
}
