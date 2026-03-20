class ApodData {
  final String title;
  final String date;
  final String explanation;
  final String url;
  final String mediaType;

  ApodData({
    required this.title,
    required this.date,
    required this.explanation,
    required this.url,
    required this.mediaType,
  });

  factory ApodData.fromJson(Map<String, dynamic> json) {
    return ApodData(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
      mediaType: json['media_type'] ?? 'image',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date,
        'explanation': explanation,
        'url': url,
        'mediaType': mediaType,
      };

  static ApodData fromMap(Map<String, dynamic> map) => ApodData(
        title: map['title'],
        date: map['date'],
        explanation: map['explanation'],
        url: map['url'],
        mediaType: map['mediaType'],
      );
}