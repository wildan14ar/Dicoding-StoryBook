import 'package:http/http.dart' as http;
import '../api/api_service.dart';
import '../model/login_result.dart';
import '../model/story.dart';

class StoryRepository {
  final ApiService apiService;

  StoryRepository(this.apiService);

  Future<LoginResult> login(String email, String password) {
    return apiService.loginUser(email: email, password: password);
  }

  Future<http.Response> register(String name, String email, String password) {
    return apiService.registerUser(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<List<Story>> getStories(
    String token, {
    int? page,
    int? size,
    int? location,
  }) {
    return apiService.getAllStories(
      token,
      page: page,
      size: size,
      location: location,
    );
  }

  Future<Story> getDetailStory(String token, String id) {
    return apiService.getDetailStory(token, id);
  }

  Future<http.StreamedResponse> addStory({
    required String token,
    required String description,
    required String filePath,
    double? lat,
    double? lon,
  }) {
    return apiService.addNewStory(
      token: token,
      description: description,
      filePath: filePath,
      lat: lat,
      lon: lon,
    );
  }
}
