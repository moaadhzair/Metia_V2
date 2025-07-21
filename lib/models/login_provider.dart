import 'dart:convert';

import 'package:flutter/material.dart' hide Title;
import 'package:metia/anilist/anime.dart';
import 'package:metia/data/user/credentials.dart';
import 'package:metia/data/user/profile.dart';
import 'package:metia/data/user/user_data.dart';
import 'package:metia/data/user/user_library.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  bool hasNextPage = true;
  bool _isLoggedIn = false;
  Profile _user = Profile(
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

  Future<String> _getAuthKey() async {
    return await UserData.getAuthKey();
  }

  void logIn(String authKey) async {
    await UserData.saveAuthKey(authKey);
    await _getUserData();
    _isLoggedIn = true;
    notifyListeners();
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
      print('Error fetching viewer: ${viewerData['errors']}');
      return;
    }

    final viewer = viewerData['data']['Viewer'];
    final int userId = viewer['id'];

    // Step 2: Query MediaListCollection with userId
    const String mediaListQuery = '''
    query (\$type: MediaType!, \$userId: Int!) {
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
        'variables': {'type': 'ANIME', 'userId': userId},
      }),
    );

    final Map<String, dynamic> mediaListData = jsonDecode(
      mediaListResponse.body,
    );

    if (mediaListData['errors'] != null) {
      print('Error fetching media list: ${mediaListData['errors']}');
      return;
    }

    final mediaListGroups =
        mediaListData['data']['MediaListCollection']['lists'] as List;

    // Parse media list groups
    List<MediaListGroup> parsedGroups = mediaListGroups.map((group) {
      return MediaListGroup(
        name: group['name'],
        entries: (group['entries'] as List).map((entry) {
          final mediaJson = entry['media'];
          return MediaListEntry(
            id: entry['id'],
            progress: entry['progress'],
            status: entry['status'],
            media: Media.fromJson(mediaJson),
          );
        }).toList(),
      );
    }).toList();

    // Fetch user activities as before
    ActivityPage activityPage = await _fetchUserActivities(userId, 1, 20);

    // Assign your Profile object
    _user = Profile(
      name: viewer["name"],
      avatarLink: viewer["avatar"]["large"],
      bannerImage: viewer["bannerImage"] ?? "null",
      id: userId,
      statistics: Statistics.fromJson(viewer["statistics"]["anime"]),
      userLibrary: UserLibrary(library: parsedGroups),
      userActivityPage: activityPage,
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
}
