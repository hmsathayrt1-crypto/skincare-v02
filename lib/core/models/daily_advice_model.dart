/// نموذج "نصيحة اليوم" المولّدة بالذكاء الاصطناعي.
/// يقابل كائن `advice` المُعاد من `GET /api/daily_advice.php`.
class DailyAdviceModel {
  final String adviceDate;
  final String adviceText;

  // بيانات الطقس وقت التوليد
  final double? temperature;
  final double? humidity;
  final String? weatherDescription;

  // بيانات الموقع
  final String? cityName;
  final double? elevation;

  DailyAdviceModel({
    required this.adviceDate,
    required this.adviceText,
    this.temperature,
    this.humidity,
    this.weatherDescription,
    this.cityName,
    this.elevation,
  });

  factory DailyAdviceModel.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as Map<String, dynamic>?) ?? const {};
    final location = (json['location'] as Map<String, dynamic>?) ?? const {};
    return DailyAdviceModel(
      adviceDate: json['advice_date']?.toString() ?? '',
      adviceText: json['advice_text']?.toString() ?? '',
      temperature: _toDouble(weather['temperature']),
      humidity: _toDouble(weather['humidity']),
      weatherDescription: weather['description']?.toString(),
      cityName: location['city_name']?.toString(),
      elevation: _toDouble(location['elevation']),
    );
  }

  /// هل تتوفر بيانات طقس صالحة للعرض في الودجت؟
  bool get hasWeather => temperature != null;

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse('$v');
  }
}
