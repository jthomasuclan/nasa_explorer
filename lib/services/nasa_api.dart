import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/apod_data.dart';

class NasaApiService {
  static const String _apiKey = 'pHbr4P1TZskz5z89E2DUZ3Tihu8RFaOpNtw89EZ7';
  static const String _baseUrl = 'https://api.nasa.gov/planetary/apod';

  static Future<ApodData?> fetchApod() async {
    try {
      final uri = Uri.parse('$_baseUrl?api_key=$_apiKey');
      developer.log('Fetching APOD: $uri', name: 'NasaApiService');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      developer.log('Status: ${response.statusCode}', name: 'NasaApiService');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApodData.fromJson(json);
      }
      return null;
    } catch (e) {
      developer.log('Network error: $e', name: 'NasaApiService');
      return null;
    }
  }
}