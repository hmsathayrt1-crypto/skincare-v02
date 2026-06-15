class ScanModel {
  final int id;
  final String imagePath;
  final String scanDate;
  final double? latitude;
  final double? longitude;
  final double? temperature;
  final double? humidity;
  final double? uvIndex;
  final String? weatherDescription;
  final String? cityName;
  final String? condition;
  final double? confidence;
  final String? consultation;
  final String? notes;

  ScanModel({
    required this.id,
    required this.imagePath,
    required this.scanDate,
    this.latitude,
    this.longitude,
    this.temperature,
    this.humidity,
    this.uvIndex,
    this.weatherDescription,
    this.cityName,
    this.condition,
    this.confidence,
    this.consultation,
    this.notes,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      imagePath: json['image_path'] ?? '',
      scanDate: json['scan_date'] ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      temperature: _toDouble(json['temperature']),
      humidity: _toDouble(json['humidity']),
      uvIndex: _toDouble(json['uv_index']),
      weatherDescription: json['weather_description'],
      cityName: json['city_name'],
      condition: json['cv_detected_condition'] ?? json['condition'],
      confidence: _toDouble(json['cv_confidence_score'] ?? json['confidence']),
      consultation: json['nlp_consultation_text'] ?? json['consultation'],
      notes: json['notes'],
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse('$v');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_path': imagePath,
        'scan_date': scanDate,
        'latitude': latitude,
        'longitude': longitude,
        'temperature': temperature,
        'humidity': humidity,
        'uv_index': uvIndex,
        'weather_description': weatherDescription,
        'city_name': cityName,
        'cv_detected_condition': condition,
        'cv_confidence_score': confidence,
        'nlp_consultation_text': consultation,
        'notes': notes,
      };
}
