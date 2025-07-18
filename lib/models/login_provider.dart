import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:metia/data/user/profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class LoginProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  late String _authKey;
  Profile _user = Profile(
    name: "Default",
    avatarLink:
        "https://s4.anilist.co/file/anilistcdn/user/avatar/large/default.png",
    bannerImage: "",
    id: 0,
    userStatus: [],
    userLibrary: [],
    statistics: Statistics(),
  );

  bool get isLoggedIn => _isLoggedIn;
  Profile get user => _user;

  void logIn(String authKey) async {
    _authKey = authKey;
    await _getUser();
    _isLoggedIn = true;
    notifyListeners();
  }

  void reloadUserData() async {
    await _getUser();
    notifyListeners();
  }

  Future<void> _getUser() async {
    //for now just get the name and the id and the avatar link
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
        'Authorization': 'Bearer $_authKey',
      },
      body: jsonEncode(body),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    var viewer = data['data']['Viewer'];

    Profile user = Profile(
      name: viewer["name"],
      avatarLink: viewer["avatar"]["large"],
      bannerImage: viewer["bannerImage"] ?? "null",
      id: viewer["id"],
      userStatus: [],
      userLibrary: [],
      statistics: Statistics.fromJson(viewer["statistics"]["anime"]),
    );
    _user = user;
  }

  void logOut() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
