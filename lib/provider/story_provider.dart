import 'package:flutter/material.dart';
import '../common/preferences_helper.dart';
import '../data/api/api_service.dart';
import '../data/repository/story_repository.dart';
import '../data/model/story.dart';

class StoryProvider extends ChangeNotifier {
  final StoryRepository _storyRepository = StoryRepository(ApiService());
  final PreferencesHelper _preferencesHelper = PreferencesHelper();

  int _page = 1;
  final int _size = 10; // Number of items per page
  bool _hasMore = true; // Flag to check if more data is available

  bool get hasMore => _hasMore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Story> _stories = [];
  List<Story> get stories => _stories;

  Future<void> fetchStories({
    bool isInitial = false,
    bool withLocation = false,
  }) async {
    // Jangan fetch jika sedang loading atau tidak ada data lagi (kecuali saat initial)
    if (_isLoading || (!_hasMore && !isInitial)) return;

    try {
      _isLoading = true;
      if (isInitial) {
        _page = 1;
        _hasMore = true;
        _stories.clear(); // Reset list untuk fetch ulang
        _errorMessage = ''; // Reset pesan error
      }
      notifyListeners();

      final token = await _preferencesHelper.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Tentukan flag location: 1 = hanya cerita dengan koordinat, 0 = semua cerita
      final locationFlag = withLocation ? 1 : 0;
      final result = await _storyRepository.getStories(
        token,
        page: _page,
        size: _size,
        location: locationFlag,
      );

      _stories.addAll(result);
      _page++;
      _hasMore =
          result.length ==
          _size; // Jika batch penuh, kemungkinan masih ada data

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Mengambil detail satu story
  Future<Story?> getDetail(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _preferencesHelper.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final story = await _storyRepository.getDetailStory(token, id);

      _isLoading = false;
      notifyListeners();
      return story;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Menambah story baru, lalu otomatis fetch ulang list
  Future<bool> addStory(
    String description,
    String filePath, {
    double? lat,
    double? lon,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _preferencesHelper.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await _storyRepository.addStory(
        token: token,
        description: description,
        filePath: filePath,
        lat: lat,
        lon: lon,
      );

      if (response.statusCode == 201) {
        // Berhasil: reload stories from the beginning
        await fetchStories(isInitial: true);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            'Gagal menambah story (status code: \${response.statusCode})';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to upload story: \$e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
