import 'package:skincare_v02/core/models/user_model.dart';
import 'package:skincare_v02/core/network/dio_client.dart';
import 'package:skincare_v02/core/constants/api_endpoints.dart';

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class AuthService {
  final DioClient _client = DioClient();

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? skinType,
  }) async {
    final resp = await _client.dio.post(
      ApiEndpoints.register,
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (skinType != null) 'skin_type': skinType,
      },
    );
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] == true) {
      final authResp = AuthResponse.fromJson(data);
      await _client.saveToken(authResp.token);
      return authResp;
    }
    throw Exception(data['message'] ?? 'Registration failed');
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final resp = await _client.dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] == true) {
      final authResp = AuthResponse.fromJson(data);
      await _client.saveToken(authResp.token);
      return authResp;
    }
    throw Exception(data['message'] ?? 'Login failed');
  }

  Future<void> logout() async {
    try {
      await _client.dio.post(ApiEndpoints.logout);
    } catch (_) {}
    await _client.clearToken();
  }

  Future<UserModel> getProfile() async {
    final resp = await _client.dio.get(ApiEndpoints.profile);
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return UserModel.fromJson(data['user'] ?? data);
    }
    throw Exception(data['message'] ?? 'Failed to load profile');
  }

  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    final resp = await _client.dio.post(ApiEndpoints.profile, data: updates);
    final data = resp.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return UserModel.fromJson(data['user'] ?? data);
    }
    throw Exception(data['message'] ?? 'Failed to update profile');
  }
}
