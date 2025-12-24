import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://story-api.dicoding.dev/v1';

  Future login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login');
    }
  }

  Future register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register');
    }
  }

  Future getAllStories(String token, {int page = 1, int size = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stories?page=$page&size=$size'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return StoryListResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load stories');
    }
  }

  Future getStoryDetail(String token, String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stories/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return StoryDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load story detail');
    }
  }

  Future uploadStory(
      String token,
      String description,
      File photo,
      ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/stories'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['description'] = description;

    var multipartFile = await http.MultipartFile.fromPath('photo', photo.path);
    request.files.add(multipartFile);

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return UploadResponse.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Failed to upload story');
    }
  }
}