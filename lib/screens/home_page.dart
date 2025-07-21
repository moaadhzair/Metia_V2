import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:metia/models/login_provider.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    initDeepLinks();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _tabController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    // Handle links
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) async {
      
      String authorizationCode = uri.toString().replaceAll(
        "metia://?code=",
        "",
      );
      final Uri tokenEndpoint = Uri.https('anilist.co', '/api/v2/oauth/token');
      final Map<String, String> payload = {
        'grant_type': 'authorization_code',
        'client_id': '25588',
        'client_secret': 'QCzgwOKG6kJRzRL91evKRXXGfDCHlmgXfi44A0Ok',
        'redirect_uri': 'metia://',
        'code': authorizationCode,
      };

      try {
        final http.Response response = await http.post(
          tokenEndpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
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
    Provider.of<UserProvider>(context).isLoggedIn;

    return Scaffold(
      appBar: AppBar(
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
        title: Text('Metia'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [LibraryPage(), ExplorerPage(), ProfilePage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (index) {
          _tabController.index = index;
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
