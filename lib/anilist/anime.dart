// anime.dart

import 'dart:ui';

class Media {
  final int id;
  final String type;
  final String status;
  final bool isAdult;
  final String bannerImage;
  final Title title;
  final String coverImage;
  final Color? color;

  Media({
    required this.id,
    required this.type,
    required this.status,
    required this.isAdult,
    required this.bannerImage,
    required this.title,
    required this.coverImage,
    required this.color,
  });
  static Color? _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // add full opacity if missing
    }
    return Color(int.parse('0x$hexColor'));
  }

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      isAdult: json['isAdult'] ?? false,
      bannerImage: json['bannerImage'] ?? '',
      title: Title.fromJson(json['title'] ?? {}),
      coverImage: json['coverImage']?['large'] ?? '',
      color: _parseColor(json['coverImage']?['color']),
    );
  }
}

class Title {
  final String english;
  final String romaji;
  final String nativeTitle;

  Title({
    required this.english,
    required this.romaji,
    required this.nativeTitle,
  });

  factory Title.fromJson(Map<String, dynamic> json) {
    return Title(
      english: json['english'] ?? '',
      romaji: json['romaji'] ?? '',
      nativeTitle: json['native'] ?? '',
    );
  }
}

class PageInfo {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;

  PageInfo({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.hasNextPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      total: json['total'] ?? 0,
      perPage: json['perPage'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      lastPage: json['lastPage'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}

class UserActivity {
  final String type;
  final String status;
  final String progress;
  final int likeCount;
  final int createdAt;
  final Media media;

  UserActivity({
    required this.type,
    required this.status,
    required this.progress,
    required this.likeCount,
    required this.createdAt,
    required this.media,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      progress: json['progress'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      createdAt: json['createdAt'] ?? 0,
      media: Media.fromJson(json['media'] ?? {}),
    );
  }
}
