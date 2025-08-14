import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:metia/anilist/anime.dart';
import 'package:metia/data/user/profile.dart';
import 'package:metia/models/login_provider.dart';
import 'package:metia/tools/general_tools.dart';
import 'package:metia/widgets/explorer_anime_card.dart';
import 'package:metia/widgets/library_anime_card.dart';
import 'package:provider/provider.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  late Profile user;
  late double itemWidth;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    itemWidth =
        MediaQuery.of(context).size.width /
        Tools.getResponsiveCrossAxisVal(
          MediaQuery.of(context).size.width,
          itemWidth: 135,
        );
    user = Provider.of<UserProvider>(context).user;
    bool isLoggedIn = Provider.of<UserProvider>(context).isLoggedIn;
    return Scaffold(
      body: isLoggedIn
          ? _buidlExplorerBody()
          : Center(child: Text("Please log in to explore anime")),
    );
  }

  _buidlExplorerBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: !(Platform.isIOS || Platform.isMacOS)
          ? RefreshIndicator(
              onRefresh: () async {
                await Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).reloadUserData();
              },
              child: CustomScrollView(
                slivers: [
                  if (Platform.isIOS || Platform.isMacOS)
                    CupertinoSliverRefreshControl(
                      onRefresh: () async {
                        await Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).reloadUserData();
                      },
                    ),
                  _buildSection(user.explorerContent[0], "Trending Now"),
                  SliverToBoxAdapter(child: SizedBox(height: 16)),
                  _buildSection(user.explorerContent[1], "Popular This Season"),
                  SliverToBoxAdapter(child: SizedBox(height: 16)),
                  _buildSection(
                    user.explorerContent[2],
                    "Upcoming This Season",
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 16)),
                  _buildSection(user.explorerContent[3], "All Time Popular"),
                  SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Text(
                      "Top 100 Anime",
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.fontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildTop100AnimeSection(user.explorerContent[4]),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                if (Platform.isIOS || Platform.isMacOS)
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      await Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).reloadUserData();
                    },
                  ),
                _buildSection(user.explorerContent[0], "Trending Now"),
                SliverToBoxAdapter(child: SizedBox(height: 16)),
                _buildSection(user.explorerContent[1], "Popular This Season"),
                SliverToBoxAdapter(child: SizedBox(height: 16)),
                _buildSection(user.explorerContent[2], "Upcoming This Season"),
                SliverToBoxAdapter(child: SizedBox(height: 16)),
                _buildSection(user.explorerContent[3], "All Time Popular"),
                SliverToBoxAdapter(
                  child: Text(
                    "Top 100 Anime",
                    style: TextStyle(
                      fontSize: Theme.of(
                        context,
                      ).textTheme.headlineSmall!.fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _buildTop100AnimeSection(user.explorerContent[4]),
              ],
            ),
    );
  }

  _buildTop100AnimeSection(List<Media> entries) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: entries.length, (
        context,
        index,
      ) {
        return _animeCardLandscape(entries[index]);
      }),
    );
  }

  _animeCardLandscape(Media media) {
    String title =
        media.title.english ??
        media.title.romaji ??
        media.title.native ??
        "NO TITLE";
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: media.coverImage.large,
            height: 100,
            width: 75,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(width: 75, height: 100, color: Colors.grey[300]),
            errorWidget: (context, url, error) =>
                Container(width: 75, height: 100, color: Colors.grey),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: SizedBox(
              height: 100,
              child: AspectRatio(
                aspectRatio: 1900 / 400,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    media.bannerImage != null
                        ? CachedNetworkImage(
                            imageUrl: media.bannerImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[300]),
                            errorWidget: (context, url, error) =>
                                Container(color: Colors.grey),
                          )
                        : Container(color: media.color),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent.withAlpha(50),
                            Colors.black.withAlpha(100),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: ColorScheme.fromSeed(
                                seedColor: media.color ?? Colors.blue,
                              ).onInverseSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildSection(List<Media> entries, String headLine) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headLine,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 268,
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(width: 0),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                Media media = entries[index];
                bool alreadyInLibrary = false;
                String listName = "";
                for (var group in user.userLibrary.library) {
                  for (var i = 0; i < group.entries.length; i++) {
                    if (group.entries[i].media.id == media.id) {
                      alreadyInLibrary = true;
                      listName = group.name;
                    }
                  }
                }
                
                return SizedBox(
                  width:
                      itemWidth +
                      ((MediaQuery.of(context).orientation ==
                              Orientation.landscape)
                          ? -12.4
                          : -3.5),
                  child: ExplorerAnimeCard(
                    alreadyInLibrary: alreadyInLibrary,
                    onLibraryChanged: () {},
                    context: context,
                    anime: media,
                    index: index,
                    listName: listName,
                  ),
                );
              },
              itemCount: entries.length,
            ),
          ),
        ],
      ),
    );
  }
}
