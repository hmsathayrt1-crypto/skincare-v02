class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? skinType;
  final String? avatarPath;
  final String? dateOfBirth;
  final String? gender;
  final String? createdAt;
  final int? scansCount;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.skinType,
    this.avatarPath,
    this.dateOfBirth,
    this.gender,
    this.createdAt,
    this.scansCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      skinType: json['skin_type'],
      avatarPath: json['avatar_path'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      createdAt: json['created_at'],
      scansCount: json['scans_count'] is int
          ? json['scans_count']
          : int.tryParse('${json['scans_count']}'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'skin_type': skinType,
        'avatar_path': avatarPath,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'created_at': createdAt,
        'scans_count': scansCount,
      };
}
