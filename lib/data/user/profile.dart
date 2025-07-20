// profile.dart

import 'package:metia/anilist/anime.dart';

class Profile {
  String name;
  String avatarLink;
  String bannerImage;
  int id;
  List<dynamic> userStatus;
  List<dynamic> userLibrary;
  Statistics statistics;
  List<UserActivity> userActivity;

  Profile({
    required this.name,
    required this.avatarLink,
    required this.bannerImage,
    required this.id,
    required this.userStatus,
    required this.userLibrary,
    required this.statistics,
    required this.userActivity,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? "Unknown",
      avatarLink: json['avatarLink'] ?? "",
      bannerImage: json['bannerImage'] ?? "",
      id: json['id'] ?? 0,
      userStatus: json['userStatus'] ?? [],
      userLibrary: json['userLibrary'] ?? [],
      statistics: Statistics.fromJson(json['statistics']),
      userActivity: (json['userActivity'] as List<dynamic>? ?? [])
          .map((e) => UserActivity.fromJson(e))
          .toList(),
    );
  }
}

class Statistics {
  List<Map<String, int>> stats = [];

  Statistics();

  Statistics.fromJson(Map<String, dynamic> anime) {
    for (final key in anime.keys) {
      if (key == 'minutesWatched') {
        final minutes = anime[key] as int;
        if (minutes >= 120) {
          stats.add({'Hours\nWatched': minutes ~/ 60});
        } else {
          stats.add({'Minute\nWatched': minutes});
        }
      } else {
        if (key == "episodesWatched") {
          stats.add({"Episodes\nWatched": anime[key]});
        }
        if (key == "count") {
          stats.add({"Count\n": anime[key]});
        }
      }
    }
  }
}

class ActivityPage {
  final PageInfo pageInfo;
  final List<UserActivity> activities;

  ActivityPage({
    required this.pageInfo,
    required this.activities,
  });

  factory ActivityPage.fromJson(Map<String, dynamic> json) {
    return ActivityPage(
      pageInfo: PageInfo.fromJson(json['pageInfo']),
      activities: (json['activities'] as List<dynamic>)
          .map((e) => UserActivity.fromJson(e))
          .toList(),
    );
  }
}

