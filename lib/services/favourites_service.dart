import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/apod_data.dart';

// FavouritesService uses BOTH local storage (shared_preferences)
// and cloud storage (Firestore) for data persistence.
// Local storage ensures offline access.
// Cloud storage syncs favourites across devices.

class FavouritesService {
  static const String _localKey = 'favourites';

  // Get current user ID for Firestore
  static String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Firestore collection reference
  static CollectionReference? get _collection {
    final uid = _userId;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favourites');
  }

  // ─── LOAD ────────────────────────────────────────────────────────────────

  static Future<List<ApodData>> loadFavourites() async {
    try {
      // Try loading from Firestore first
      final collection = _collection;
      if (collection != null) {
        final snapshot = await collection.get();
        if (snapshot.docs.isNotEmpty) {
          final cloudFavourites = snapshot.docs
              .map((doc) => ApodData.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
          // Sync to local storage
          await _saveToLocal(cloudFavourites);
          return cloudFavourites;
        }
      }
    } catch (e) {
      // If Firestore fails, fall back to local storage
    }

    // Fall back to local storage (works offline)
    return await _loadFromLocal();
  }

  // ─── SAVE ────────────────────────────────────────────────────────────────

  static Future<void> saveFavourite(ApodData apod) async {
    // Save to local storage immediately
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_localKey) ?? [];
    if (!stored.any((s) => jsonDecode(s)['date'] == apod.date)) {
      stored.add(jsonEncode(apod.toMap()));
      await prefs.setStringList(_localKey, stored);
    }

    // Save to Firestore (cloud)
    try {
      final collection = _collection;
      if (collection != null) {
        await collection.doc(apod.date).set(apod.toMap());
      }
    } catch (e) {
      // Firestore save failed — local storage still saved
    }
  }

  // ─── REMOVE ──────────────────────────────────────────────────────────────

  static Future<void> removeFavourite(String date) async {
    // Remove from local storage
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_localKey) ?? [];
    stored.removeWhere((s) => jsonDecode(s)['date'] == date);
    await prefs.setStringList(_localKey, stored);

    // Remove from Firestore (cloud)
    try {
      final collection = _collection;
      if (collection != null) {
        await collection.doc(date).delete();
      }
    } catch (e) {
      // Firestore delete failed — local storage still updated
    }
  }

  // ─── CHECK ───────────────────────────────────────────────────────────────

  static Future<bool> isFavourite(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_localKey) ?? [];
    return stored.any((s) => jsonDecode(s)['date'] == date);
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  static Future<List<ApodData>> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_localKey) ?? [];
    return stored.map((s) => ApodData.fromMap(jsonDecode(s))).toList();
  }

  static Future<void> _saveToLocal(List<ApodData> favourites) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = favourites.map((f) => jsonEncode(f.toMap())).toList();
    await prefs.setStringList(_localKey, stored);
  }
}