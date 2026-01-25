import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class AuthService {
  final String baseUrl = "http://192.168.1.11:8080/api";

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
      print("Data berhasil disimpan ke PostgreSQL!");
    } else {
      throw Exception("Gagal menyimpan data ke backend");
    }
  }

  Future<Map<String, dynamic>?> getChildInfo(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/child/$uid'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Gagal ambil data: $e");
    }
    return null;
  }
}