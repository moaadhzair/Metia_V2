import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:metia/anilist/anime.dart';
import 'package:metia/data/user/profile.dart';

class UserLibrary {
  //TODO: here is where you do the change an anime from a list to a custom list ...
  //add anime to a list()
  //add anime to custom list
  //delete anime.....
  List<MediaListGroup> library;
  UserLibrary({required this.library});
}

class MediaListGroup {
  final String name;
  final List<MediaListEntry> entries;
  final bool isInteractive;
  final Color color;

  MediaListGroup({
    required this.color,
    required this.name,
    required this.entries,
    required this.isInteractive,
  });

  factory MediaListGroup.fromJson(Map<String, dynamic> json) {
    return MediaListGroup(
      color: json['name'] == "Watching" ? Colors.green : json['name'] == "Airing" ? Colors.orange : Colors.white,
      isInteractive:
          true, // true by default cause it was passed in straigt from the graphql json code
      name: json['name'],
      entries: (json['entries'] as List)
          .map((entry) => MediaListEntry.fromJson(entry))
          .toList(),
    );
  }
}

class MediaListEntry {
  final int id;
  final int? progress;
  final String status;
  final Media media;

  MediaListEntry({
    required this.id,
    this.progress,
    required this.status,
    required this.media,
  });

  factory MediaListEntry.fromJson(Map<String, dynamic> json) {
    return MediaListEntry(
      id: json['id'],
      progress: json['progress'],
      status: json['status'],
      media: Media.fromJson(json['media']),
    );
  }
}
