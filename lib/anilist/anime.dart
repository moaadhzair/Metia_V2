// anime.dart

import 'dart:ui';

class Media {
  final int id;
  final String? description;
  final List<String>? genres;
  final Title title;
  final int? episodes;
  final int? averageScore;
  final String? season;
  final int? seasonYear;
  final String? status;
  final String? type;
  final bool? isAdult;
  final String? bannerImage;
  final CoverImage coverImage;
  final int? duration;
  final NextAiringEpisode? nextAiringEpisode;
  final Color? color;

  Media({
    required this.id,
    required this.title,
    required this.coverImage,
    this.description,
    this.genres,
    this.episodes,
    this.averageScore,
    this.season,
    this.seasonYear,
    this.status,
    this.type,
    this.isAdult,
    this.bannerImage,
    this.duration,
    this.nextAiringEpisode,
    this.color,
  });

  static Color? _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6)
      hexColor = 'FF$hexColor'; // Add opacity if missing
    return Color(int.parse('0x$hexColor'));
  }

  factory Media.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Media(
        id: 0,
        title: Title.fromJson({}),
        coverImage: CoverImage.fromJson({}),
      );
    }

    return Media(
      id: json['id'] ?? 0,
      title: Title.fromJson(json['title'] ?? {}),
      description: json['description'],
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      episodes: json['episodes'],
      averageScore: json['averageScore'],
      season: json['season'],
      seasonYear: json['seasonYear'],
      status: json['status'],
      type: json['type'],
      isAdult: json['isAdult'],
      bannerImage: json['bannerImage'],
      duration: json['duration'],
      nextAiringEpisode: json['nextAiringEpisode'] != null
          ? NextAiringEpisode.fromJson(json['nextAiringEpisode'])
          : null,
      coverImage: CoverImage.fromJson(json['coverImage'] ?? {}),
      color: _parseColor(json['coverImage']?['color']),
    );
  }
}

class Title {
  final String? romaji;
  final String? english;
  final String? native;

  Title({this.romaji, this.english, this.native});

  factory Title.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Title();
    }
    return Title(
      romaji: json['romaji'],
      english: json['english'],
      native: json['native'],
    );
  }
}

class CoverImage {
  final String large;
  final String extraLarge;
  final String medium;

  CoverImage({
    required this.large,
    required this.extraLarge,
    required this.medium,
  });

  factory CoverImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CoverImage(large: '', extraLarge: '', medium: '');
    }
    return CoverImage(
      large: json['large'] ?? '',
      extraLarge: json['extraLarge'] ?? '',
      medium: json['medium'] ?? '',
    );
  }
}

class NextAiringEpisode {
  final int airingAt;
  final int episode;

  NextAiringEpisode({required this.airingAt, required this.episode});

  factory NextAiringEpisode.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return NextAiringEpisode(airingAt: 0, episode: 0);
    }
    return NextAiringEpisode(
      airingAt: json['airingAt'] ?? 0,
      episode: json['episode'] ?? 0,
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

  factory PageInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PageInfo(
        total: 0,
        perPage: 0,
        currentPage: 1,
        lastPage: 1,
        hasNextPage: false,
      );
    }
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

  factory UserActivity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return UserActivity(
        type: '',
        status: '',
        progress: '',
        likeCount: 0,
        createdAt: 0,
        media: Media.fromJson({}),
      );
    }
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
