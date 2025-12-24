class Story {
  final String id;
  final String name;
  final String description;
  final String photoUrl;
  final DateTime createdAt;
  final double? lat;
  final double? lon;

  Story({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    this.lat,
    this.lon,
  });

  factory Story.fromJson(Map json) {
    return Story(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lat: json['lat']?.toDouble(),
      lon: json['lon']?.toDouble(),
    );
  }
}

class StoryListResponse {
  final bool error;
  final String message;
  final List listStory;

  StoryListResponse({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory StoryListResponse.fromJson(Map json) {
    return StoryListResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      listStory: (json['listStory'] as List?)
          ?.map((item) => Story.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class StoryDetailResponse {
  final bool error;
  final String message;
  final Story? story;

  StoryDetailResponse({
    required this.error,
    required this.message,
    this.story,
  });

  factory StoryDetailResponse.fromJson(Map json) {
    return StoryDetailResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      story: json['story'] != null ? Story.fromJson(json['story']) : null,
    );
  }
}