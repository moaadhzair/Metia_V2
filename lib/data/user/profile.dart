// profile.dart

import 'package:flutter/material.dart';
import 'package:metia/anilist/anime.dart';
import 'package:metia/data/user/user_library.dart';

class Profile extends ChangeNotifier{
  String name;
  String avatarLink;
  String bannerImage;
  int id;
  UserLibrary userLibrary;
  Statistics statistics;
  List<Map<String, dynamic>> userLists;
  ActivityPage userActivityPage; // Now stores ActivityPage instead of List

  Profile({
    required this.name,
    required this.avatarLink,
    required this.bannerImage,
    required this.id,
    required this.userLibrary,
    required this.statistics,
    required this.userActivityPage,
    required this.userLists,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userLists: json['mediaListOptions']['animeList']['customLists'],
      name: json['name'] ?? "Unknown",
      avatarLink: json['avatarLink'] ?? "",
      bannerImage: json['bannerImage'] ?? "",
      id: json['id'] ?? 0,
      userLibrary: json['userLibrary'] ?? [],
      statistics: Statistics.fromJson(json['statistics']),
      userActivityPage: ActivityPage.fromJson({
        'pageInfo': json['pageInfo'] ?? {},
        'activities': json['userActivity'] ?? [],
      }),
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

  ActivityPage({required this.pageInfo, required this.activities});

  factory ActivityPage.fromJson(Map<String, dynamic> json) {
    return ActivityPage(
      pageInfo: PageInfo.fromJson(json['pageInfo']),
      activities: (json['activities'] as List<dynamic>)
          .map((e) => UserActivity.fromJson(e))
          .toList(),
    );
  }
}
