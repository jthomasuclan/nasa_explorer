import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/apod_data.dart';

class FavouritesService {
  static const String _key = 'favourites';

  static Future<List<ApodData>> loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];
    return stored.map((s) => ApodData.fromMap(jsonDecode(s))).toList();
  }

  static Future<void> saveFavourite(ApodData apod) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];
    if (!stored.any((s) => jsonDecode(s)['date'] == apod.date)) {
      stored.add(jsonEncode(apod.toMap()));
      await prefs.setStringList(_key, stored);
    }
  }

  static Future<void> removeFavourite(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];
    stored.removeWhere((s) => jsonDecode(s)['date'] == date);
    await prefs.setStringList(_key, stored);
  }

  static Future<bool> isFavourite(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];
    return stored.any((s) => jsonDecode(s)['date'] == date);
  }
}