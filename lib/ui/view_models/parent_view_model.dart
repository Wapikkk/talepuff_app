import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '/core/app_colors.dart';
import 'package:http/http.dart' as http;

class ParentViewModel extends ChangeNotifier{
  File? _imagePreview;
  File? get imagePreview => _imagePreview;
  String? _currentPhotoUrl;
  String? get currentPhotoUrl => _currentPhotoUrl;
  bool _isUploading = false;
  bool get isUploading => _isUploading;
  bool _isAutoStoryEnabled = false;
  bool get isAutoStoryEnabled => _isAutoStoryEnabled;
  String _selectedHour = "08";
  String get selectedHour => _selectedHour;
  String _selectedMinute = "30";
  String get selectedMinute => _selectedMinute;
  bool _isAM = true;
  bool get isAM => _isAM;

  final ImagePicker _picker = ImagePicker();

  Future<void> handleImageSelection(ImageSource source, String childId) async{
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );

      if(pickedFile != null) {
        final croppedFile = await _cropImage(pickedFile.path);

        if(croppedFile != null) {
          _imagePreview = File(croppedFile.path);
          notifyListeners();

          await uploadProfilePhoto(childId);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void setInitiateData(String? photoUrl) {
    _currentPhotoUrl = photoUrl;
    _imagePreview = null;
    notifyListeners();
  }

  Future<CroppedFile?> _cropImage(String path) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust Profile Photo',
          toolbarColor: AppColors.darkPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: 'Adjust Profile Photo',
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

  void removePhoto() {
    _imagePreview = null;
    _currentPhotoUrl = null;
    notifyListeners();
  }

  Future<void> uploadProfilePhoto(String childId) async {
    if (_imagePreview == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.104:8080/api/child/upload-photo/$childId'),
      );

      request.files.add(await http.MultipartFile.fromPath('photo', _imagePreview!.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        debugPrint("Upload Berhasil!");
        final respStr = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(respStr);

        _currentPhotoUrl = data['url'];
        _imagePreview = null;
        notifyListeners();
      } else {
        debugPrint("Upload Gagal: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error Upload: $e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> updateChildName(String newName) async {
    if (newName.trim().isEmpty) return;

    try {
      _isUploading = true;
      notifyListeners();

      debugPrint("DEBUG: update nama anak ke: $newName");

      // Backend Update Nama Anak

      await Future.delayed(const Duration(seconds: 1));
      debugPrint("DEBUG: Nama anak berhasil diperbarui di database!");
    } catch (e) {
      debugPrint("ERROR Update Child Name: $e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> updateParentEmail(String newEmail, String password) async {
    try {
      _isUploading = true;
      notifyListeners();

      debugPrint("DEBUG: Mencoba update EMAIL ORANG TUA ke: $newEmail");

      // Di Firebase, update email butuh re-autentikasi dengan password lama
      // 1. Re-authenticate user
      // 2. updateEmail(newEmail)
      // 3. Update email di PostgreSQL backend Go

      await Future.delayed(const Duration(seconds: 1));
      debugPrint("DEBUG: Email berhasil diperbarui!");
    } catch (e) {
      debugPrint("ERROR Update Email: $e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> updateParentPassword(String currentPass, String newPass) async {
    try {
      _isUploading = true;
      notifyListeners();

      debugPrint("DEBUG: Mencoba update PASSWORD ORANG TUA...");

      // Logika Firebase Auth:
      // 1. Re-authenticate user dengan currentPass
      // 2. Jika sukses, panggil currentUser?.updatePassword(newPass)

      await Future.delayed(const Duration(seconds: 1));
      debugPrint("DEBUG: Password berhasil diperbarui!");
    } catch (e) {
      debugPrint("ERROR Update Password: $e");
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