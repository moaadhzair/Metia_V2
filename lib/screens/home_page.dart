import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:metia/models/login_provider.dart';
import 'package:metia/models/theme_provider.dart';
import 'package:metia/screens/home/explorer_page.dart';
import 'package:metia/screens/home/library_page.dart';
import 'package:metia/screens/home/profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription<Uri>? _linkSubscription;

  final List<Widget> _tabs = [LibraryPage(), ExplorerPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) async {
      final authorizationCode = uri.toString().replaceAll("metia://?code=", "");

      final tokenEndpoint = Uri.https('anilist.co', '/api/v2/oauth/token');
      final payload = {
        'grant_type': 'authorization_code',
        'client_id': '25588',
        'client_secret': 'QCzgwOKG6kJRzRL91evKRXXGfDCHlmgXfi44A0Ok',
        'redirect_uri': 'metia://',
        'code': authorizationCode,
      };

      try {
        final response = await http.post(
          tokenEndpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (mounted) {
            Provider.of<UserProvider>(
              context,
              listen: false,
            ).logIn(responseData['access_token'].toString());
          }
        } else {
          throw Exception('Failed to retrieve access token: ${response.body}');
        }
      } catch (e) {
        throw Exception('Request failed: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        actions: [
          if (Provider.of<UserProvider>(context).isLoggedIn)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                _switchMenuButtons(value, context);
              },
              itemBuilder: (BuildContext context) => _menuItemList(context),
            ),
        ],

        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
              height: 24,
              width: 24,
            ),
          ),
        ),
        title: const Text('Metia'),
      ),
      body: IndexedStack(index: _tabController.index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (index) {
          setState(() {
            _tabController.index = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

_menuItemList(BuildContext context) {
  return [
    const PopupMenuItem<String>(
      enabled: false,
      height: 36,
      child: Text('Library'),
    ),
    const PopupMenuItem<String>(
      value: 'refresh',
      height: 36,
      child: Text('Refresh'),
    ),
    const PopupMenuItem<String>(
      value: 'createList',
      height: 36,
      child: Text('Create a New List'),
    ),

    const PopupMenuItem<String>(
      height: 36,
      enabled: false,
      child: Text('Explorer'),
    ),
    const PopupMenuItem<String>(
      value: 'changeSource',
      height: 36,
      child: Text('Change Source'),
    ),

    const PopupMenuItem<String>(
      height: 36,
      enabled: false,
      child: Text('Profile', textAlign: TextAlign.end),
    ),
    const PopupMenuItem<String>(
      value: 'logout',
      height: 36,
      child: Text('Log Out'),
    ),
    const PopupMenuItem<String>(
      height: 36,
      enabled: false,
      child: Text('General', textAlign: TextAlign.end),
    ),
    PopupMenuItem<String>(
      value: 'revertTheme',
      height: 36,
      child: Text(
        'Swith to ${Provider.of<ThemeProvider>(context, listen: false).isDarkMode ? "Light" : "Dark"} Mode',
      ),
    ),
    const PopupMenuItem<String>(
      value: 'Settings',
      height: 36,
      child: Text('Settings'),
    ),
  ];
}

_switchMenuButtons(value, context) {
  switch (value) {
    case 'logout':
      Provider.of<UserProvider>(context, listen: false).logOut();
      break;
    case 'refresh':
      break;
    case 'createList':
      break;
    case 'changeSource':
      break;
    case 'revertTheme':
      bool isDarkMode = Provider.of<ThemeProvider>(
        context,
        listen: false,
      ).isDarkMode;
      if (isDarkMode) {
        Provider.of<ThemeProvider>(context, listen: false).setLightMode();
      } else {
        Provider.of<ThemeProvider>(context, listen: false).setDarkMode();
      }
  }
}
