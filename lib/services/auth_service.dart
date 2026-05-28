import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data, {String? imagePath}) async {
    try {
      dynamic payload;
      
      if (imagePath != null) {
        payload = FormData.fromMap({
          ...data,
          'add_user_profile_picture': await MultipartFile.fromFile(imagePath),
        });
      } else {
        payload = data;
      }

      final response = await _dio.post(
        ApiConstants.register,
        data: payload,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.user);
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      rethrow;
    }
  }
}
