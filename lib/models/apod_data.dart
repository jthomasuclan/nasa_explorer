class ApodData {
  final String title;      //  the five fields that make up a NASA picture
  final String date;
  final String explanation;
  final String url;
  final String mediaType;

  ApodData({
    required this.title,        // constructor - all fields are required
    required this.date,
    required this.explanation,
    required this.url,
    required this.mediaType,
  });

  factory ApodData.fromJson(Map<String, dynamic> json) {  // called when NASA API responds
    return ApodData(
      title: json['title'] ?? '',           //  ?? means if null use empty string instead of crashing
      date: json['date'] ?? '',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
      mediaType: json['media_type'] ?? 'image',  //  NASA uses media_type, dart uses mediaType
    );
  }

  Map<String, dynamic> toMap() => {   // converts object to Map for saving to SharedPreferences/Firestore
        'title': title,
        'date': date,
        'explanation': explanation,
        'url': url,
        'mediaType': mediaType,
      };

  static ApodData fromMap(Map<String, dynamic> map) => ApodData(  // converts saved Map back to object when loading favourites
        title: map['title'],
        date: map['date'],
        explanation: map['explanation'],
        url: map['url'],
        mediaType: map['mediaType'],
      );
}