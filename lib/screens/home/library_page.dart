import 'package:flutter/material.dart';
import 'package:metia/data/user/profile.dart';
import 'package:metia/data/user/user_library.dart';
import 'package:metia/models/login_provider.dart';
import 'package:metia/tools/general_tools.dart';
import 'package:metia/widgets/library_anime_card.dart';
import 'package:provider/provider.dart';
import 'package:metia/widgets/color_transition_tab_bar.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 0, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tabController = TabController(
      length: Provider.of<UserProvider>(
        context,
      ).user.userLibrary.library.length,
      vsync: this,
    );

    bool isLoggedIn = Provider.of<UserProvider>(context).isLoggedIn;

    return Scaffold(
      body: isLoggedIn
          ? Provider.of<UserProvider>(
                      context,
                    ).user.userLibrary.library.length ==
                    0
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Provider.of<UserProvider>(
                                context,
                              ).user.userLibrary.library.length !=
                              0
                          ? _buildTabBar()
                          : null,
                      _buildLibraryGrid(),
                    ],
                  )
          : const Center(child: Text('Please log in to view your library')),
    );
  }

  _buildTabBar() {
    Profile user = Provider.of<UserProvider>(context).user;

    return ColorTransitionTabBar(
      tabs: user.userLibrary.library.map((e) {
        return "${e.name} (${e.entries.length})";
      }).toList(),
      controller: _tabController,
      tabColors: user.userLibrary.library.map((e) {
        return e.color == Colors.white
            ? Theme.of(context).unselectedWidgetColor
            : e.color;
      }).toList(),
    );
  }

  _buildLibraryGrid() {
    Profile user = Provider.of<UserProvider>(context).user;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TabBarView(
          controller: _tabController,
          children: user.userLibrary.library.map((e) {
            return RefreshIndicator.adaptive(
              child: GridView.builder(
                key: PageStorageKey('library ${e.name}'),
                cacheExtent: 500,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Tools.getResponsiveCrossAxisVal(
                    MediaQuery.of(context).size.width,
                    itemWidth: 135,
                  ),
                  mainAxisExtent:
                      /*state.state == "New Episode" ? 283 : */
                      268,
                  // crossAxisSpacing: 10,
                  // mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: e.entries.length,
                itemBuilder: (context, index) {
                  MediaListEntry anime = e.entries[index];
      
                  return AnimeCard(
                    key: ValueKey(anime.id),
                    context: context,
                    index: index,
                    tabName: anime.status,
                    anime: anime,
      
                    onLibraryChanged: () {
                      print("a new anime is added or removed");
                      // _fetchAnimeLibrary(false);
                      // _fetchPopularAnime();
                    },
                  );
                },
              ),
      
              onRefresh: () {
                return Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).reloadUserData();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
