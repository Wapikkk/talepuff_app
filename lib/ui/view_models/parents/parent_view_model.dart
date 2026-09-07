import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '/core/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParentViewModel extends ChangeNotifier{
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
        Uri.parse("${dotenv.env['API_BASE_URL'] ?? ''}/api/child/upload-photo/$childId"),
      );

      request.files.add(await http.MultipartFile.fromPath('photo', _imagePreview!.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        debugPrint("Upload successful!");
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