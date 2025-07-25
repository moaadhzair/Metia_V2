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
    final group = MediaListGroup(
      color: json['name'] == "Watching"
          ? Colors.green
          : json['name'] == "Airing"
          ? Colors.orange
          : Colors.white,
      isInteractive: true,
      name: json['name'],
      entries: [], // placeholder, will populate below
    );

    final parsedEntries = (json['entries'] as List).map((entryJson) {
      final entry = MediaListEntry.fromJson(entryJson);
      entry.setGroup(group);
      return entry;
    }).toList();

    // Create a new group with proper entries assigned
    return MediaListGroup(
      color: group.color,
      name: group.name,
      isInteractive: group.isInteractive,
      entries: parsedEntries,
    );
  }
}

class MediaListEntry {
  final int id;
  final int? progress;
  final String status;
  final Media media;

  // Back-reference to the parent group
  MediaListGroup? _group;
  MediaListGroup? getGroup() => _group;

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

  // Internal setter for the group (used only during list construction)
  void setGroup(MediaListGroup group) {
    _group = group;
  }
}
