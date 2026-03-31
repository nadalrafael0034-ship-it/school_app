import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final _api = ApiService.instance.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<UserModel> getMe() async {
    final response = await _api.get('/auth/me');
    return UserModel.fromJson(response.data['user']);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _api.put('/auth/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
