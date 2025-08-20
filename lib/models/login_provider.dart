import 'dart:convert';

import 'package:flutter/material.dart' hide Title;
import 'package:metia/anilist/anime.dart';
import 'package:metia/data/user/credentials.dart';
import 'package:metia/data/user/profile.dart';
import 'package:metia/data/user/user_data.dart';
import 'package:metia/data/user/user_library.dart';
import 'package:metia/models/logger.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  bool hasNextPage = true;
  bool _isLoggedIn = false;
  Profile _user = Profile(
    explorerContent: [],
    userLists: [],
    userActivityPage: ActivityPage(
      pageInfo: PageInfo(
        total: 0,
        perPage: 0,
        currentPage: 0,
        lastPage: 0,
        hasNextPage: false,
      ),
      activities: [],
    ),
    name: "Default",
    avatarLink:
        "https://s4.anilist.co/file/anilistcdn/user/avatar/large/default.png",
    bannerImage: "",
    id: 0,
    userLibrary: UserLibrary(library: []),
    statistics: Statistics(),
  );

  int _currentActivityPage = 1;
  bool _isLoadingMoreActivities = false;

  bool get isLoggedIn => _isLoggedIn;
  Profile get user => _user;
  List<UserActivity> get userActivities => _user.userActivityPage.activities;

  UserProvider() {
    _initializeLoginState();
  }

  Future<void> loadMoreActivities() async {
    if (_isLoadingMoreActivities) return; // prevent duplicate loads

    _isLoadingMoreActivities = true;
    _currentActivityPage++;

    try {
      ActivityPage newPage = await _fetchUserActivities(
        _user.id,
        _currentActivityPage,
        20,
      );

      hasNextPage = newPage.pageInfo.hasNextPage;

      // Append new activities to existing list
      _user.userActivityPage.activities.addAll(newPage.activities);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoadingMoreActivities = false;
    }
  }

  Future<void> _initializeLoginState() async {
    String authKey = await _getAuthKey();

    _isLoggedIn = authKey != "empty";

    if (_isLoggedIn) {
      notifyListeners();
      await _getUserData();
    }

    notifyListeners();
  }

  Future<String> getAuthKey() async {
    return _getAuthKey();
  }

  Future<String> _getAuthKey() async {
    return await UserData.getAuthKey();
  }

  void logIn(String authKey) async {
    await UserData.saveAuthKey(authKey);
    Logger.log('Saved auth key of the user', level: 'INFO');
    await _getUserData();
    Logger.log('got user data with the name of ${user.name}', level: 'INFO');
    _isLoggedIn = true;
    notifyListeners();
    Logger.log('Notified the listening build methods to rebuild the app', level: 'INFO');
  }

  Future<void> reloadUserData() async {
    await _getUserData();
    notifyListeners();
  }

  Future<void> _getUserData() async {
    String authKey = await _getAuthKey();
    const String url = 'https://graphql.anilist.co';

    // Step 1: Query Viewer for user info + ID
    const String viewerQuery = '''
    query {
      Viewer {
        mediaListOptions {
          animeList {
            customLists
          }
        }
        id
        name
        avatar {
          large
        }
        bannerImage
        statistics {
          anime {
            count
            episodesWatched
            minutesWatched
          }
        }
      }
    }
  ''';

    final viewerResponse = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authKey',
        'Accept': 'application/json',
      },
      body: jsonEncode({'query': viewerQuery}),
    );

    final Map<String, dynamic> viewerData = jsonDecode(viewerResponse.body);

    if (viewerData['errors'] != null) {
      // handle error, e.g. throw or return early
      debugPrint('Error fetching viewer: ${viewerData['errors']}');
      return;
    }

    final viewer = viewerData['data']['Viewer'];
    final int userId = viewer['id'];

    // Step 2: Query MediaListCollection with userId
    const String mediaListQuery = '''
          query (
        \$type: MediaType!,
        \$userId: Int!,
        \$season: MediaSeason,
        \$seasonYear: Int,
        \$nextSeason: MediaSeason,
        \$nextYear: Int
      ) {
        MediaListCollection(type: \$type, userId: \$userId) {
          lists {
            name
            entries {
              id
              progress
              status
              media {
                id
                type
                status(version: 2)
                isAdult
                bannerImage
                description
                genres
                title {
                  english
                  romaji
                  native
                }
                episodes
                averageScore
                season
                seasonYear
                coverImage {
                  large
                  extraLarge
                  medium
                  color
                }
                duration
                nextAiringEpisode {
                  airingAt
                  episode
                }
              }
            }
          }
        }

        trending: Page(page: 1, perPage: 99) {
          media(sort: TRENDING_DESC, type: ANIME, isAdult: false) {
            ...mediaFields
          }
        }
        season: Page(page: 1, perPage: 99) {
          media(season: \$season, seasonYear: \$seasonYear, sort: POPULARITY_DESC, type: ANIME, isAdult: false) {
            ...mediaFields
          }
        }
        nextSeason: Page(page: 1, perPage: 99) {
          media(season: \$nextSeason, seasonYear: \$nextYear, sort: POPULARITY_DESC, type: ANIME, isAdult: false) {
            ...mediaFields
          }
        }
        popular: Page(page: 1, perPage: 99) {
          media(sort: POPULARITY_DESC, type: ANIME, isAdult: false) {
            ...mediaFields
          }
        }
        top: Page(page: 1, perPage: 100) {
          media(sort: SCORE_DESC, type: ANIME, isAdult: false) {
            ...mediaFields
          }
        }
      }

      fragment mediaFields on Media {
        id
                type
                status(version: 2)
                isAdult
                bannerImage
                description
                genres
                title {
                  english
                  romaji
                  native
                }
                episodes
                averageScore
                season
                seasonYear
                coverImage {
                  large
                  extraLarge
                  medium
                  color
                }
                duration
                nextAiringEpisode {
                  airingAt
                  episode
                }
      }

  ''';

    final mediaListResponse = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authKey',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': mediaListQuery,
        'variables': {
          'type': 'ANIME',
          'userId': userId,
          "season": "SPRING",
          "seasonYear": 2025,
          "nextSeason": "SUMMER",
          "nextYear": 2025,
        },
      }),
    );

    final Map<String, dynamic> mediaListData = jsonDecode(
      mediaListResponse.body,
    );

    if (mediaListData['errors'] != null) {
      debugPrint('Error fetching media list: ${mediaListData['errors']}');
      return;
    }

    final mediaListGroups =
        mediaListData['data']['MediaListCollection']['lists'] as List;

    // Parse media list groups
    List<MediaListGroup> parsedGroups = mediaListGroups.map((group) {
      // Step 1: Create the MediaListGroup first with empty entries
      final mediaListGroup = MediaListGroup(
        color: group['name'] == "Watching" ? Colors.green : Colors.white,
        isInteractive: group['name'] != "Airing",
        name: group['name'],
        entries: [], // will fill this next
        isCustom: ![
          'Watching',
          'Planning',
          'Completed',
          'Paused',
          'Dropped',
        ].contains(group['name']),
      );

      // Step 2: Fill in the entries and set the group reference
      List<MediaListEntry> entries = (group['entries'] as List).map((entry) {
        final mediaJson = entry['media'];
        var mediaListEntry = MediaListEntry(
          id: entry['id'],
          progress: entry['progress'],
          status: entry['status'],
          media: Media.fromJson(mediaJson),
        );

        // Use your setGroup() method
        mediaListEntry.setGroup(mediaListGroup);

        return mediaListEntry;
      }).toList();

      // Step 3: Add entries to the group
      mediaListGroup.entries.addAll(entries);

      return mediaListGroup; // ✅ return the filled group
    }).toList();

    //Step 1: Create the Airing group early (empty for now)
    final airingGroup = MediaListGroup(
      color: Colors.orange,
      name: "Airing",
      entries: [],
      isInteractive: false,
      isCustom: false,
    );

    // Step 2: Extract "airing" entries and reassign their group
    for (final group in parsedGroups) {
      if (["Planning", "Watching"].contains(group.name)) {
        for (final entry in group.entries) {
          final media = entry.media;
          final nextEp = media.nextAiringEpisode;

          if (nextEp != null && nextEp.episode > (entry.progress ?? 0) + 1) {
            // Reassign entry to airing group
            MediaListEntry newEntry = MediaListEntry(
              id: entry.id,
              progress: entry.progress,
              status: entry.status,
              media: media,
            );
            newEntry.setGroup(airingGroup);
            airingGroup.entries.add(newEntry);
          }
        }
      }
    }

    // Step 3: Insert the airing group at the beginning
    parsedGroups.insert(0, airingGroup);

    const desiredOrder = [
      "Airing",
      "Watching",
      "Planning",
      "Completed",
      "Paused",
      "Dropped",
    ];

    parsedGroups.sort((a, b) {
      int indexA = desiredOrder.indexOf(a.name ?? "");
      int indexB = desiredOrder.indexOf(b.name ?? "");
      return indexA.compareTo(indexB);
    });

    // Fetch user activities as before
    ActivityPage activityPage = await _fetchUserActivities(userId, 1, 20);

    final customLists = List<String>.from(
      viewer['mediaListOptions']['animeList']['customLists'],
    );

    final defaultLists = [
      {'name': 'Watching', 'isCustom': false},
      {'name': 'Planning', 'isCustom': false},
      {'name': 'Completed', 'isCustom': false},
      {'name': 'Dropped', 'isCustom': false},
      {'name': 'Paused', 'isCustom': false},
    ];

    final custom = customLists.map((name) => {'name': name, 'isCustom': true});

    final userList = [...defaultLists, ...custom];

    // Assign your Profile object
    _user = Profile(
      explorerContent: [
        (mediaListData["data"]["trending"]["media"] as List)
            .map((entry) => Media.fromJson(entry))
            .toList(),
        (mediaListData["data"]["season"]["media"] as List)
            .map((entry) => Media.fromJson(entry))
            .toList(),
        (mediaListData["data"]["nextSeason"]["media"] as List)
            .map((entry) => Media.fromJson(entry))
            .toList(),
        (mediaListData["data"]["popular"]["media"] as List)
            .map((entry) => Media.fromJson(entry))
            .toList(),
        (mediaListData["data"]["top"]["media"] as List)
            .map((entry) => Media.fromJson(entry))
            .toList(),
      ],
      name: viewer["name"],
      avatarLink: viewer["avatar"]["large"],
      bannerImage: viewer["bannerImage"] ?? "null",
      id: userId,
      statistics: Statistics.fromJson(viewer["statistics"]["anime"]),
      userLibrary: UserLibrary(library: parsedGroups),
      userActivityPage: activityPage,
      userLists: userList,
    );
  }

  Future<ActivityPage> _fetchUserActivities(
    int userId,
    int page,
    int perPage,
  ) async {
    const String url = 'https://graphql.anilist.co';
    String authKey = await _getAuthKey();

    final query = '''
    query (\$id: Int, \$type: ActivityType, \$page: Int, \$perPage: Int, ) {
      Page(page: \$page, perPage: \$perPage) {
        pageInfo {
          total
          perPage
          currentPage
          lastPage
          hasNextPage
        }
        activities(userId: \$id, type: \$type, sort: [PINNED, ID_DESC]) {
          ... on ListActivity {
            type
            status
            progress
            likeCount
            createdAt
            media {
              id
              type
              status(version: 2)
              isAdult
              bannerImage
              description
              genres
              title {
                english
                romaji
                native
              }
              episodes
              averageScore
              season
              seasonYear
              coverImage {
                large
                extraLarge
                medium
                color
              }
              duration
              nextAiringEpisode {
                airingAt
                episode
              }
            }
          }
        }
      }
    }
  ''';

    final variables = {
      "id": userId,
      "type": "ANIME_LIST",
      "page": page,
      "perPage": perPage,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authKey',
      },
      body: jsonEncode({"query": query, "variables": variables}),
    );

    final data = jsonDecode(response.body)['data']['Page'];
    var src = ActivityPage.fromJson(data);
    return src;
  }

  void logOut() {
    _isLoggedIn = false;
    UserData.deletAuthKey();
    notifyListeners();
  }

  Future<void> createCustomList(String newListName) async {
    const String url = 'https://graphql.anilist.co';

    List userAnimeLists = user.userLists;

    List<String> userAnimeCustomLists = userAnimeLists
        .where((list) => list['isCustom'] == true)
        .map<String>((list) => list['name'] as String)
        .toList();

    userAnimeCustomLists.add(newListName);

    final Map<String, dynamic> body = {
      'query': '''
      mutation(\$animeListOptions: MediaListOptionsInput) {
        UpdateUser(animeListOptions: \$animeListOptions) {
          id
        }
      }
    ''',
      'variables': {
        'animeListOptions': {'customLists': userAnimeCustomLists},
      },
    };

    String authKey = await _getAuthKey();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authKey}',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
    } else {
      print('Failed to add custom list: ${response.body}');
    }
  }
}
