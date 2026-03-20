import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/apod_data.dart';

class NasaApiService {
  static const String _apiKey = 'pHbr4P1TZskz5z89E2DUZ3Tihu8RFaOpNtw89EZ7';
  static const String _baseUrl = 'https://api.nasa.gov/planetary/apod';

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static Future<ApodData?> fetchApod({DateTime? date}) async {
    try {
      final dateParam = date != null ? '&date=${_formatDate(date)}' : '';
      final uri = Uri.parse('$_baseUrl?api_key=$_apiKey$dateParam');
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