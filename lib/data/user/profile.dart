import 'dart:ui';
import 'package:flutter/material.dart';

class Profile {
  String name;
  String avatarLink;
  String bannerImage;
  int id;
  List<dynamic> userStatus;
  List<dynamic> userLibrary;
  Statistics statistics;

  Profile({
    required this.name,
    required this.avatarLink,
    required this.bannerImage,
    required this.id,
    required this.userStatus,
    required this.userLibrary,
    required this.statistics,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? "Unknown",
      avatarLink: json['avatarLink'] ?? "",
      bannerImage: json['bannerImage'] ?? "",
      id: json['id'] ?? 0,
      userStatus: json['userStatus'] ?? [],
      userLibrary: json['userLibrary'] ?? [],
      statistics: json['statistics'] ?? Statistics.fromJson(json['statistics']),
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
          stats.add({'Minute\nsWatched': minutes});
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
