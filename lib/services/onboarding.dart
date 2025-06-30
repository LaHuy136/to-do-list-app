import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:to_do_list_app/models/onboarding.dart';

class OnboardingAPI {
  static Future<List<OnboardingData>> fetchOnboarding() async {
    final response = await http.get(
      Uri.parse('http://192.168.38.126:3000/onboarding/'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => OnboardingData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load onboarding data');
    }
  }
}
