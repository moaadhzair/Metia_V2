import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:metia/anilist/anime.dart';
import 'package:metia/data/user/credentials.dart';
import 'package:metia/data/user/profile.dart';
import 'package:metia/data/user/user_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class LoginProvider extends ChangeNotifier {
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
    userStatus: [],
    userLibrary: [],
    statistics: Statistics(),
  );

  int _currentActivityPage = 1;
  bool _isLoadingMoreActivities = false;

  bool get isLoggedIn => _isLoggedIn;
  Profile get user => _user;
  List<UserActivity> get userActivities => _user.userActivityPage.activities;

  LoginProvider() {
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
      await _getUser();
    }
    notifyListeners();
  }

  Future<String> _getAuthKey() async {
    return await UserData.getAuthKey();
  }

  void logIn(String authKey) async {
    await UserData.saveAuthKey(authKey);
    await _getUser();
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> reloadUserData() async {
    await _getUser();
    notifyListeners();
  }

  Future<void> _getUser() async {
    String authKey = await _getAuthKey();

    const String url = 'https://graphql.anilist.co';
    final Map<String, dynamic> body = {
      'query': '''
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
    ''',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authKey',
      },
      body: jsonEncode(body),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    var viewer = data['data']['Viewer'];
    ActivityPage activityPage = await _fetchUserActivities(viewer["id"], 1, 20);

    _user = Profile(
      name: viewer["name"],
      avatarLink: viewer["avatar"]["large"],
      bannerImage: viewer["bannerImage"] ?? "null",
      id: viewer["id"],
      userStatus: [],
      userLibrary: [],
      statistics: Statistics.fromJson(viewer["statistics"]["anime"]),
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
              title {
                english
                romaji
                native
              }
              coverImage {
                large
                color
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
