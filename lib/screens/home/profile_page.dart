import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:metia/anilist/anime.dart';
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
  late final ScrollController _scrollController;
  bool _hasReachedBottom = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
          if (!_hasReachedBottom) {
            Provider.of<UserProvider>(
              context,
              listen: false,
            ).loadMoreActivities();
            _hasReachedBottom = true;
          }
        } else {
          // Reset flag if user scrolls back up
          if (_hasReachedBottom) {
            _hasReachedBottom = false;
          }
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Provider.of<UserProvider>(context).isLoggedIn;

    return Scaffold(
      body: isLoggedIn
          ? _buildProfile(context) // <- pass context
          : CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
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
                ),
              ],
            ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    Profile user = Provider.of<UserProvider>(context).user;
    bool hasBanner = user.bannerImage != "null" && user.bannerImage != "";

    return Platform.isAndroid
        ? RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            onRefresh: () {
              return Provider.of<UserProvider>(
                context,
                listen: false,
              ).reloadUserData();
            },

            child: _buildProfileBody(hasBanner, user, false),
          )
        : _buildProfileBody(hasBanner, user, true);
  }

  Widget _buildProfileBody(hasBanner, user, isApple) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (isApple)
          CupertinoSliverRefreshControl(

            onRefresh: () async {
              await Provider.of<UserProvider>(
                context,
                listen: false,
              ).reloadUserData();
            },
          ),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              // Banner Background
              SizedBox(
                height: 125,
                width: double.infinity,
                child: hasBanner
                    ? CachedNetworkImage(
                        imageUrl: user.bannerImage,
                        fit: BoxFit.cover,
                      )
                    : Container(color: Colors.deepPurple),
              ),

              // Gradient Overlay
              Container(
                height: 125,
                width: double.infinity,
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

              // Avatar + Name Row
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: user.avatarLink,
                        height: 100,
                      ),
                    ),
                    const SizedBox(width: 10),
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
            ],
          ),
        ),
        //user's statistics
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 100,
              child: Center(
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 5),
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
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text("Activites:", style: TextStyle(fontWeight: FontWeight.w700, fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize)),
        )),
        
        //user's activity
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final activity = user.userActivityPage.activities[index];
              return Column(
                children: [
                  if (index != 0 ||
                      index != user.userActivityPage.activities.length)
                    const SizedBox(height: 2),
                  _buildActivityTile(activity),
                ],
              );
            }, childCount: user.userActivityPage.activities.length),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: Center(
              child: Text(
                Provider.of<UserProvider>(context).hasNextPage
                    ? "Loading more..."
                    : "No more activities.",
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTile(UserActivity activity) {
    DateTime createdDate = DateTime.fromMillisecondsSinceEpoch(
      activity.createdAt * 1000,
    );
    Duration difference = DateTime.now().difference(createdDate);

    String time = "";
    if (difference.inDays >= 1) {
      time = '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      time = '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      time = '${difference.inMinutes}m ago';
    } else {
      time = 'Just now';
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: activity.media.coverImage.large,
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
                    activity.media.bannerImage != null
                        ? CachedNetworkImage(
                            imageUrl: activity.media.bannerImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[300]),
                            errorWidget: (context, url, error) =>
                                Container(color: Colors.grey),
                          )
                        : Container(color: activity.media.color),
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
                            activity.status == "watched episode"
                                ? "Watched episode ${activity.progress} of ${activity.media.title.english ?? activity.media.title.romaji ?? activity.media.title.native}"
                                : "${activity.status[0].toUpperCase()}${activity.status.substring(1)} ${activity.media.title.english ?? activity.media.title.romaji ?? activity.media.title.native}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: ColorScheme.fromSeed(
                                seedColor: activity.media.color ?? Colors.blue,
                              ).onInverseSurface,
                            ),
                          ),
                          Text(
                            time,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
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
