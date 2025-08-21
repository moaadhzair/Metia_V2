import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:metia/anilist/anime.dart';
import 'package:metia/data/user/profile.dart';
import 'package:metia/models/login_provider.dart';
import 'package:metia/models/logger.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
  final bool isCustom;

  MediaListGroup({
    required this.color,
    required this.name,
    required this.entries,
    required this.isInteractive,
    required this.isCustom,
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
      entries: [],
      isCustom: ![
        'Watching',
        'Planning',
        'Completed',
        'Paused',
        'Dropped',
      ].contains(json['name']),
    );

    final parsedEntries = (json['entries'] as List).map((entryJson) {
      final entry = MediaListEntry.fromJson(entryJson);
      entry.setGroup(group);
      return entry;
    }).toList();

    return MediaListGroup(
      color: group.color,
      name: group.name,
      isInteractive: group.isInteractive,
      entries: parsedEntries,
      isCustom: group.isCustom,
    );
  }

  Future<String?> _getAuthKey(BuildContext context) async {
    await Logger.log('_getAuthKey called');
    final loginProvider = Provider.of<UserProvider>(context, listen: false);
    return loginProvider.getAuthKey();
  }

  Future<void> addToCustomList(
    BuildContext context,
    MediaListEntry entry,
    String customList,
  ) async {
    await Logger.log(
      'addToCustomList called',
      details: 'mediaId=${entry.media.id}, customList=$customList',
    );
    final authKey = await _getAuthKey(context);
    final url = Uri.parse('https://graphql.anilist.co');

    const query = r'''
    mutation(
  $id: Int
  $mediaId: Int
  $status: MediaListStatus
  $score: Float
  $progress: Int
  $progressVolumes: Int
  $repeat: Int
  $private: Boolean
  $notes: String
  $customLists: [String]
  $hiddenFromStatusLists: Boolean
  $advancedScores: [Float]
  $startedAt: FuzzyDateInput
  $completedAt: FuzzyDateInput
) {
  SaveMediaListEntry(
    id: $id
    mediaId: $mediaId
    status: $status
    score: $score
    progress: $progress
    progressVolumes: $progressVolumes
    repeat: $repeat
    private: $private
    notes: $notes
    customLists: $customLists
    hiddenFromStatusLists: $hiddenFromStatusLists
    advancedScores: $advancedScores
    startedAt: $startedAt
    completedAt: $completedAt
  ) {
    id
    mediaId
    status
    score
    advancedScores
    progress
    progressVolumes
    repeat
    priority
    private
    hiddenFromStatusLists
    customLists
    notes
    updatedAt
    startedAt {
      year
      month
      day
    }
    completedAt {
      year
      month
      day
    }
    user {
      id
      name
    }
    media {
      id
      title {
        userPreferred
      }
      coverImage {
        large
      }
      type
      format
      status
      episodes
      volumes
      chapters
      averageScore
      popularity
      isAdult
      startDate {
        year
      }
    }
  }
}

    ''';

    final variables = {
      'mediaId': entry.media.id,
      'customLists': [customList],
      'hiddenFromStatusLists': true,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authKey',
      },
      body: jsonEncode({'query': query, 'variables': variables}),
    );

    if (response.statusCode != 200) {
      await Logger.log(
        'Failed to add to custom list',
        level: 'ERROR',
        details: response.body,
      );
    }
  }

  Future<void> addToStatusList(
    BuildContext context,
    int mediaId,
    String status,
  ) async {
    await Logger.log(
      'addToStatusList called',
      details: 'mediaId=$mediaId, status=$status',
    );
    final authKey = await _getAuthKey(context);
    final url = Uri.parse('https://graphql.anilist.co');

    const query = r'''
    mutation($mediaId: Int, $status: MediaListStatus, $hiddenFromStatusLists: Boolean, $customLists: [String]
  ) {
      SaveMediaListEntry(
        mediaId: $mediaId,
        customLists: $customLists
        status: $status
        hiddenFromStatusLists: $hiddenFromStatusLists
      ) {
        id
        customLists
        hiddenFromStatusLists
      }
    }
    ''';

    final variables = {
      'mediaId': mediaId,
      'status': status.toUpperCase(),
      'customLists': [],
      'hiddenFromStatusLists': false,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authKey',
      },
      body: jsonEncode({'query': query, 'variables': variables}),
    );

    if (response.statusCode != 200) {
      await Logger.log(
        'Failed to add to status list',
        level: 'ERROR',
        details: response.body,
      );
    }
  }

  Future<void> deleteEntry(BuildContext context, int entryId) async {
    await Logger.log(
      'deleteEntry called',
      details: 'entryId=$entryId',
    );
    final authKey = await _getAuthKey(context);
    final url = Uri.parse('https://graphql.anilist.co');

    const query = r'''
    mutation($id: Int) {
      DeleteMediaListEntry(id: $id) {
        deleted
      }
    }
    ''';

    final variables = {'id': entryId};

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authKey',
      },
      body: jsonEncode({'query': query, 'variables': variables}),
    );

    if (response.statusCode != 200) {
      await Logger.log(
        'Failed to delete entry',
        level: 'ERROR',
        details: response.body,
      );
    }
  }

  static Future<void> changeFromCustomListToStatus(
    int mediaId,
    String customListName,
    String statusName,
  ) async {
    await Logger.log(
      'changeFromCustomListToStatus called',
      details: 'mediaId=$mediaId, customListName=$customListName, statusName=$statusName',
    );
    //await addAnimeToStatus(mediaId, statusName);
  }

  static Future<void> removeAnimeFromCustomList() async {
    await Logger.log('removeAnimeFromCustomList called');
  }

  Future<void> moveEntryFromCustomListToCustomList(
    BuildContext context,
    MediaListEntry entry,
    String newCustomList,
  ) async {
    await Logger.log(
      'moveEntryFromCustomListToCustomList called',
      details: 'mediaId=${entry.media.id}, newCustomList=$newCustomList',
    );
    await addToCustomList(context, entry, newCustomList);
  }

  Future<void> changeEntryStatus(
    BuildContext context,
    MediaListEntry entry,
    String listName,
    bool isCustom,
  ) async {
    await Logger.log(
      'changeEntryStatus called',
      details: 'mediaId=${entry.media.id}, listName=$listName, isCustom=$isCustom',
    );
    if (isCustom) {
      if (entry.getGroup()!.isCustom) {
        await Logger.log(
          "Send the entry from custom to custom",
          details: 'mediaId=${entry.media.id}, listName=$listName',
        );
        await moveEntryFromCustomListToCustomList(context, entry, listName);
      } else {
        await Logger.log(
          "Send the entry from status to custom",
          details: 'mediaId=${entry.media.id}, listName=$listName',
        );
        await addToCustomList(context, entry, listName);
      }
    } else {
      if (entry.getGroup()!.isCustom) {
        await Logger.log(
          "Send the entry from not custom to status",
          details: 'mediaId=${entry.media.id}, listName=$listName',
        );
        await addToStatusList(
          context,
          entry.media.id,
          listName == "Watching" ? "CURRENT" : listName,
        );
      } else {
        await Logger.log(
          "Send the entry from not status to status",
          details: 'mediaId=${entry.media.id}, listName=$listName',
        );
        await addToStatusList(
          context,
          entry.media.id,
          listName == "Watching" ? "CURRENT" : listName,
        );
      }
    }
  }

  Future<List<String>> _getCustomLists(
    BuildContext context,
    int mediaId,
  ) async {
    await Logger.log(
      '_getCustomLists called',
      details: 'mediaId=$mediaId',
    );
    final authKey = await _getAuthKey(context);
    final url = Uri.parse('https://graphql.anilist.co');

    const query = r'''
    query($mediaId: Int) {
      Media(id: $mediaId) {
        mediaListEntry {
          customLists
        }
      }
    }
    ''';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authKey',
      },
      body: jsonEncode({
        'query': query,
        'variables': {'mediaId': mediaId},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final customListsMap =
          data['data']['Media']['mediaListEntry']['customLists'];
      return List<String>.from(
        customListsMap?.keys.where((k) => customListsMap[k] == true) ?? [],
      );
    } else {
      await Logger.log(
        'Failed to get custom lists',
        level: 'ERROR',
        details: response.body,
      );
      return [];
    }
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
