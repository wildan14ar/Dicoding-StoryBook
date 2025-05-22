import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../common/constants.dart';
import '../model/login_result.dart';
import '../model/story.dart';

class ApiService {
  // Register
  Future<http.Response> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
  }

  // Login
  Future<LoginResult> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        return LoginResult.fromJson(data['loginResult']);
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Login gagal');
    }
  }

  // Get All Stories
  Future<List<Story>> getAllStories(
    String token, {
    int? page,
    int? size,
    int? location = 0, // Default 0 as per API docs
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (size != null) queryParams['size'] = size.toString();
    if (location != null) queryParams['location'] = location.toString();

    final url = Uri.parse(
      '$baseUrl/stories',
    ).replace(queryParameters: queryParams);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        List<Story> stories =
            (data['listStory'] as List)
                .map(
                  (json) => Story.fromJson(json as Map<String, dynamic>),
                ) // Cast json
                .toList();

        return stories;
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Gagal memuat stories');
    }
  }

  // Get Detail Story
  Future<Story> getDetailStory(String token, String id) async {
    final url = Uri.parse('$baseUrl/stories/$id');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        return Story.fromJson(
          data['story'] as Map<String, dynamic>,
        ); // Cast json
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Gagal memuat detail story');
    }
  }

  // Add New Story
  Future<http.StreamedResponse> addNewStory({
    required String token,
    required String description,
    required String filePath,
    double? lat,
    double? lon,
  }) async {
    final url = Uri.parse('$baseUrl/stories');

    var request =
        http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['description'] = description;
    if (lat != null) request.fields['lat'] = lat.toString();
    if (lon != null) request.fields['lon'] = lon.toString();

    // Lampirkan file gambar
    var file = await http.MultipartFile.fromPath('photo', filePath);
    request.files.add(file);

    return await request.send();
  }
}
