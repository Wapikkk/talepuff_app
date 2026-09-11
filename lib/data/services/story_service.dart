import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoryService {
  final String baseUrl = "${dotenv.env['API_BASE_URL'] ?? ''}/api/stories";

  Future<Map<String, dynamic>?> generateStory(Map<String, dynamic> payload) async{
    try{
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      final idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse('$baseUrl/generate'),
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $idToken'
        },
        body: jsonEncode(payload)
      );

      if(response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Backend error: ${response.body}');
        throw Exception('Failed to generate story. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Service Exception: $e');
      throw Exception('Network connection failed');
    }
  }
}