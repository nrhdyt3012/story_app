import 'package:flutter/foundation.dart';
import '../data/api/api_service.dart';
import '../data/model/story.dart';

class StoryProvider with ChangeNotifier {
  final ApiService apiService;

  List<Story> _stories = [];
  Story? _selectedStory;
  bool _isLoading = false;
  String? _errorMessage;

  List<Story> get stories => _stories;
  Story? get selectedStory => _selectedStory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StoryProvider({required this.apiService});

  Future<void> fetchStories(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.getAllStories(token, size: 20);

      if (!response.error) {
        _stories = response.listStory;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStoryDetail(String token, String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.getStoryDetail(token, id);

      if (!response.error && response.story != null) {
        _selectedStory = response.story;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedStory() {
    _selectedStory = null;
    notifyListeners();
  }
}
