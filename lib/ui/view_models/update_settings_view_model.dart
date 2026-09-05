import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../ui/view_models/parent_view_model.dart';

class UpdateSettingsViewModel extends ChangeNotifier {
  bool _isLoading = false; get isLoading => _isLoading;

  Future<void> updateChildName(BuildContext context, String childId, String newName) async {
    if (newName.trim().isEmpty) return;
    _setLoading(true);

    try {
      final url = Uri.parse("${dotenv.env['API_BASE_URL'] ?? ''}/api/child/update-name/$childId");
      final response = await http.put(
        url,
        body: jsonEncode({'name': newName.trim()}),
        headers: {'Content-Type': 'application/json'},
      );

      if(!context.mounted)return;

      if (response.statusCode == 200) {
        Provider.of<ParentViewModel>(context, listen: false).updateLocalChildName(newName.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Name updated successfully!"), backgroundColor: Colors.green),
        );
        debugPrint("DEBUG: Child's name has been changed in database");
      }
    } catch (e) {
      debugPrint("ERROR Update Name: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEmail(BuildContext context, String newEmail, String currentPassword) async {
    if (newEmail.trim().isEmpty || currentPassword.isEmpty) return;
    _setLoading(true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      debugPrint("DEBUG: Starting re-authentication");
      await user.reauthenticateWithCredential(credential);
      debugPrint("DEBUG: Re-authentication success!");

      await user.verifyBeforeUpdateEmail(newEmail);
      await user.reload();

      final url = Uri.parse("${dotenv.env['API_BASE_URL'] ?? ''}/api/user/update-email/${user.uid}");
      final response = await http.put(
        url,
        body: jsonEncode({'email': newEmail.trim()}),
        headers: {'Content-Type': 'application/json'},
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email updated successfully! please check your new email"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("CATCH ERROR Update Email: $e");

      if (context.mounted) {
        String msg = "Failed to update email. Please try logging out and in again.";
        if (e.toString().contains('PigeonUserDetails')) {
          msg = "System Sync Error. Please perform a 'flutter clean' and restart.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

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

      debugPrint("DEBUG: Password has been updated in Firebase");
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