import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl = "${dotenv.env['API_BASE_URL'] ?? ''}/api";

  Future<void> registerToBackend({
    required String firebaseUid,
    required String email,
    required String childName,
    int? age,
    required String gender,
    required List<String> interests,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "firebase_uid": firebaseUid,
        "email": email,
        "child_name": childName,
        "age": age,
        "gender": gender,
        "interests": interests,
      }),
    );

    if (response.statusCode == 200) {
      print("Data has been saved in Database!");
    } else {
      throw Exception("Failed save data to backend");
    }
  }

  Future<Map<String, dynamic>?> getChildInfo(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/child/$uid'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Failed fetch data: $e");
    }
    return null;
  }
}