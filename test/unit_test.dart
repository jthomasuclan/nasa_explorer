import 'package:flutter_test/flutter_test.dart';
import 'package:nasa_explorer/models/apod_data.dart';

void main() {
  group('ApodData Model', () {
    test('fromJson creates ApodData correctly from NASA API response', () {
      // Arrange - simulate a real NASA API JSON response
      final json = {
        'title': 'Launch Plume: SpaceX Jellyfish',
        'date': '2026-03-19',
        'explanation': 'A rocket launched into the sky.',
        'url': 'https://apod.nasa.gov/apod/image/test.jpg',
        'media_type': 'image',
      };

      // Act - parse the JSON into an ApodData object
      final apod = ApodData.fromJson(json);

      // Assert - verify all fields are correctly parsed
      expect(apod.title, 'Launch Plume: SpaceX Jellyfish');
      expect(apod.date, '2026-03-19');
      expect(apod.explanation, 'A rocket launched into the sky.');
      expect(apod.url, 'https://apod.nasa.gov/apod/image/test.jpg');
      expect(apod.mediaType, 'image');
    });
  });
}