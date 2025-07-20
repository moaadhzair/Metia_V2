import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:metia/data/user/profile.dart';
import 'package:metia/models/login_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Provider.of<LoginProvider>(
      context,
    ).isLoggedIn; // Replace with actual login check logic
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (isLoggedIn)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case "logout":
                    Provider.of<LoginProvider>(context, listen: false).logOut();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Log Out'),
                ),
              ],
            ),
        ],
      ),
      body: isLoggedIn
          ? _buildProfile()
          : Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (!await launchUrl(
                    Uri.parse(
                      "https://anilist.co/api/v2/oauth/authorize?client_id=25588&redirect_uri=metia://&response_type=code",
                    ),
                  )) {
                    throw Exception('Could not launch url');
                  }
                },
                child: Text("Log In"),
              ),
            ),
    );
  }

  _buildProfile() {
    Profile user = Provider.of<LoginProvider>(context).user;
    bool hasBanner = user.bannerImage == "null" ? false : true;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          stretch: true,

          expandedHeight: 125,
          toolbarHeight: 125,
          collapsedHeight: 125,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 20,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: user.avatarLink,
                  height: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),

          flexibleSpace: FlexibleSpaceBar(
            stretchModes: [StretchMode.zoomBackground, StretchMode.fadeTitle],
            background: SizedBox(
              height: 125,
              child: Stack(
                children: [
                  hasBanner
                      ? CachedNetworkImage(
                          imageUrl: user.bannerImage,
                          width: double.maxFinite,
													 fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.maxFinite,
                          color: Colors.deepPurple,
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 100,
              child: Center(
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => SizedBox(width: 5),
                  itemCount: user.statistics.stats.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final entry = user.statistics.stats[index].entries.first;
                    return _buildDeatileTile(entry.key, entry.value);
                  },
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final activity = user.userActivity[index];
              return Column(
                children: [
                  if (index != 0 || index != user.userActivity.length)
                    const SizedBox(height: 2),
                  Card(
                    child: Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: activity.media.coverImage,
                          height: 100,
                          width: 75,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 75,
                            height: 100,
                            color: Colors.grey[300],
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 75,
                            height: 100,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: SizedBox(
                            height: 100,

                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                activity.media.bannerImage.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: activity.media.bannerImage,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                              height: 100,
                                              color: Colors.grey[300],
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              height: 100,
                                              color: Colors.grey,
                                            ),
                                      )
                                    : Container(
                                        height: 100,
                                        color: activity.media.color,
                                      ),

                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor.withAlpha(
                                          180,
                                        ), // You can change this to match your theme
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: activity.status == "watched episode"
                                        ? Text(
                                            "${activity.status[0].toUpperCase()}${activity.status.substring(1)} ${activity.progress} of ${activity.media.title.english ?? activity.media.title.romaji ?? activity.media.title.nativeTitle}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: ColorScheme.fromSeed(
                                                seedColor:
                                                    activity.media.color!,
                                              ).onInverseSurface,
                                            ),
                                          )
                                        : Text(
                                            "${activity.status[0].toUpperCase()}${activity.status.substring(1)} ${activity.media.title.english ?? activity.media.title.romaji ?? activity.media.title.nativeTitle}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: ColorScheme.fromSeed(
                                                seedColor:
                                                    activity.media.color!,
                                              ).onInverseSurface,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }, childCount: user.userActivity.length),
          ),
        ),
      ],
    );

    /*

    return Column(
      children: [
        SizedBox(
          height: 125,
          child: Stack(
            children: [
              hasBanner
                  ? Image(
                      image: Image.network(user.bannerImage).image,
                      width: double.maxFinite,
                    )
                  : Container(
                      width: double.maxFinite,
                      color: Colors.deepPurple,
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, bottom: 16),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 20,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image(
                          image: Image.network(user.avatarLink).image,
                          height: 100,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
      ],
    );*/
  }

  _buildDeatileTile(String name, int data) {
    return Card(
      child: SizedBox(
        height: 100,
        width: 100,
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Text("$data"),
          ],
        ),
      ),
    );
  }
}
