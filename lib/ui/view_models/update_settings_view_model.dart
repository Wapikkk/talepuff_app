import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateSettingsViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 1. Update Nama Anak
  Future<void> updateChildName(String childId, String newName) async {
    if (newName.trim().isEmpty) return;
    _setLoading(true);

    try {
      final url = Uri.parse('http://192.168.1.104:8080/api/child/update-name/$childId');
      final response = await http.put(
        url,
        body: jsonEncode({'name': newName.trim()}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint("DEBUG: Nama anak berhasil diubah di database Go");
      }
    } catch (e) {
      debugPrint("ERROR Update Name: $e");
    } finally {
      _setLoading(false);
    }
  }

  // 2. Update Email
  Future<void> updateEmail(String newEmail, String currentPassword) async {
    _setLoading(true);
    try {
      User? user = FirebaseAuth.instance.currentUser;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);

      debugPrint("DEBUG: Email verifikasi dikirim ke $newEmail");
    } catch (e) {
      debugPrint("ERROR Update Email: $e");
    } finally {
      _setLoading(false);
    }
  }

  // 3. Update Password
  Future<void> updatePassword(String oldPass, String newPass) async {
    _setLoading(true);
    try {
      User? user = FirebaseAuth.instance.currentUser;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPass,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPass);

      debugPrint("DEBUG: Password berhasil diperbarui di Firebase");
    } catch (e) {
      debugPrint("ERROR Update Password: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}