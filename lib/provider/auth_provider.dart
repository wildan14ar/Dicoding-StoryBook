import 'package:flutter/material.dart';
import '../common/preferences_helper.dart';
import '../data/api/api_service.dart';
import '../data/model/login_result.dart';
import '../data/repository/story_repository.dart';

class AuthProvider extends ChangeNotifier {
  final StoryRepository _storyRepository = StoryRepository(ApiService());
  final PreferencesHelper _preferencesHelper = PreferencesHelper();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _storyRepository.register(name, email, password);

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 201) {
        // User Created
        return true;
      } else {
        _errorMessage = 'Register gagal: ${response.body}';
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      LoginResult loginResult = await _storyRepository.login(email, password);
      await _preferencesHelper.setToken(loginResult.token);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _preferencesHelper.removeToken();
  }
}
