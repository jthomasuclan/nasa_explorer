import 'package:flutter_test/flutter_test.dart';
import 'package:nasa_explorer/main.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // ApodData Model Tests
  // ─────────────────────────────────────────────────────────────────────────

  group('ApodData Model', () {
    test('fromJson creates ApodData correctly from valid JSON', () {
      final json = {
        'title': 'Launch Plume: SpaceX Jellyfish',
        'date': '2026-03-19',
        'explanation': 'A rocket launched into the sky.',
        'url': 'https://apod.nasa.gov/apod/image/test.jpg',
        'media_type': 'image',
      };

      final apod = ApodData.fromJson(json);

      expect(apod.title, 'Launch Plume: SpaceX Jellyfish');
      expect(apod.date, '2026-03-19');
      expect(apod.explanation, 'A rocket launched into the sky.');
      expect(apod.url, 'https://apod.nasa.gov/apod/image/test.jpg');
      expect(apod.mediaType, 'image');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final apod = ApodData.fromJson(json);

      expect(apod.title, '');
      expect(apod.date, '');
      expect(apod.explanation, '');
      expect(apod.url, '');
      expect(apod.mediaType, 'image');
    });

    test('fromJson handles video media_type correctly', () {
      final json = {
        'title': 'Space Video',
        'date': '2026-03-20',
        'explanation': 'A video of space.',
        'url': 'https://www.youtube.com/watch?v=test',
        'media_type': 'video',
      };

      final apod = ApodData.fromJson(json);

      expect(apod.mediaType, 'video');
    });

    test('toMap converts ApodData to map correctly', () {
      final apod = ApodData(
        title: 'Test Title',
        date: '2026-03-20',
        explanation: 'Test explanation.',
        url: 'https://example.com/image.jpg',
        mediaType: 'image',
      );

      final map = apod.toMap();

      expect(map['title'], 'Test Title');
      expect(map['date'], '2026-03-20');
      expect(map['explanation'], 'Test explanation.');
      expect(map['url'], 'https://example.com/image.jpg');
      expect(map['mediaType'], 'image');
    });

    test('fromMap reconstructs ApodData correctly', () {
      final map = {
        'title': 'Test Title',
        'date': '2026-03-20',
        'explanation': 'Test explanation.',
        'url': 'https://example.com/image.jpg',
        'mediaType': 'image',
      };

      final apod = ApodData.fromMap(map);

      expect(apod.title, 'Test Title');
      expect(apod.date, '2026-03-20');
      expect(apod.explanation, 'Test explanation.');
      expect(apod.url, 'https://example.com/image.jpg');
      expect(apod.mediaType, 'image');
    });

    test('toMap and fromMap are inverse operations', () {
      final original = ApodData(
        title: 'Roundtrip Test',
        date: '2026-03-20',
        explanation: 'Testing roundtrip conversion.',
        url: 'https://example.com/image.jpg',
        mediaType: 'image',
      );

      final restored = ApodData.fromMap(original.toMap());

      expect(restored.title, original.title);
      expect(restored.date, original.date);
      expect(restored.explanation, original.explanation);
      expect(restored.url, original.url);
      expect(restored.mediaType, original.mediaType);
    });
  });
}