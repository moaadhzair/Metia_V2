import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:metia/anilist/anime.dart';
import 'package:metia/data/user/profile.dart';

import 'package:metia/data/user/user_library.dart';
import 'package:metia/models/login_provider.dart';
import 'package:metia/tools/general_tools.dart';
import 'package:provider/provider.dart';

class CustomPageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  CustomPageRoute({required this.builder})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        opaque: true,
      );
}

class AnimeCard extends StatefulWidget {
  final String tabName;
  final int index;
  final MediaListEntry anime;
  final VoidCallback? onLibraryChanged;
  final BuildContext context;

  const AnimeCard({
    required this.context,
    super.key,
    required this.tabName,
    required this.index,
    required this.anime,
    this.onLibraryChanged,
  });

  @override
  State<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> {
  late final String title;

  @override
  void initState() {
    super.initState();
    title =
        widget.anime.media.title.english ??
        widget.anime.media.title.romaji ??
        widget.anime.media.title.native ??
        "NO TITLE";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 135,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //cover
                  CupertinoContextMenu.builder(
                    enableHapticFeedback: true,
                    actions: [
                      // Watch
                      CupertinoContextMenuAction(
                        onPressed: () {
                          debugPrint("Watching $title");
                          Provider.of<UserProvider>(
                            context,
                            listen: false,
                          ).reloadUserData();
                          Navigator.of(context).pop();
                        },
                        trailingIcon: CupertinoIcons.play,
                        child: const Text("Watch"),
                      ),
                      // Copy name
                      CupertinoContextMenuAction(
                        trailingIcon: CupertinoIcons.doc_on_doc,
                        child: const Text("Copy Name"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          debugPrint("Copied \"$title\" to clipboard");
                        },
                      ),
                      // Change to another List
                      if (widget.anime.getGroup()!.isInteractive)
                        CupertinoContextMenuAction(
                          trailingIcon: CupertinoIcons.square_arrow_right,
                          child: const Text("Change to Another List"),
                          onPressed: () async {
                            //TODO: change to another list

                            await Tools.transferToAnotherList(
                              widget.anime,
                              context,
                              true,
                            );
                          },
                        ),
                      // Remove from list
                      if (widget.anime.getGroup()!.name != "Airing")
                        CupertinoContextMenuAction(
                          isDestructiveAction: true,
                          trailingIcon: CupertinoIcons.delete,
                          child: const Text("Remove From List"),
                          onPressed: () async {
                            //TODO: delete the entry from the group entry
                            widget.anime.getGroup()!.deleteEntry(
                              context,
                              widget.anime.id,
                            );
                            Provider.of<UserProvider>(
                              context,
                              listen: false,
                            ).reloadUserData();
                            Navigator.of(context).pop();
                          },
                        ),
                    ],

                    builder: (context, animation) {
                      return GestureDetector(
                        onTap: () {
                          debugPrint("tapped on lamo");
                        },
                        child: SizedBox(
                          height: 183,
                          width: 135,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                      widget.anime.media.coverImage.extraLarge,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                                widget.anime.media.nextAiringEpisode != null
                                    ? _buildEpAiring(
                                        widget.anime.media.nextAiringEpisode!,
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                  //title
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          //color: Colors.white,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.fontSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  //bottom text
                  _buildBottomText(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildBottomText() {
    MediaListGroup? mediaListGroup = widget.anime.getGroup();
    bool isNewEpisodeTab =
        widget.anime.media.nextAiringEpisode != null &&
        mediaListGroup?.name == "Airing";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: isNewEpisodeTab
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isNewEpisodeTab)
            Text(
              "${widget.anime.progress}/${widget.anime.media.episodes ?? "?"}",
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          isNewEpisodeTab
              ? Row(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${(widget.anime.media.nextAiringEpisode!.episode - 1) - widget.anime.progress!} Ep Behind",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.fontSize,
                        color: Colors.orange,
                      ),
                    ),
                    const Icon(
                      Icons.notifications_active,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ],
                )
              : Row(
                  spacing: 2,
                  children: [
                    Text(
                      widget.anime.media.averageScore == null ||
                              widget.anime.media.averageScore == 0
                          ? "0.0"
                          : widget.anime.media.averageScore
                                .toString()
                                .replaceRange(1, 1, '.'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.fontSize,
                        color: Colors.orange,
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                  ],
                ),
        ],
      ),
    );
  }

  _buildEpAiring(NextAiringEpisode nextAiring) {
    final int airingAt = nextAiring.airingAt;
    final int episode = nextAiring.episode;
    final Duration diff = DateTime.fromMillisecondsSinceEpoch(
      airingAt * 1000,
    ).difference(DateTime.now());
    if (diff.isNegative) return const SizedBox();
    if (episode > 1) return const SizedBox();

    final int days = diff.inDays;
    final int hours = diff.inHours % 24;
    final int minutes = diff.inMinutes % 60;

    String timestring = '';

    if (days < 0 || hours < 0) {
      timestring = '';
    } else if (days > 0) {
      timestring = '${days}d';
    } else if (hours > 0) {
      timestring = '${hours}h';
    } else if (minutes > 0) {
      timestring = '${minutes}m';
    } else {
      timestring = '';
    }

    timestring += ', left.';

    /*String timeString = '';
    if (days > 0) timeString += '${days}d ';
    if (hours > 0 || days > 0) timeString += '${hours}h ';
    timeString += '${minutes}m';*/

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          stops: const [0, 1], // control where each color stops
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.schedule, color: Colors.orange, size: 22),
            Material(
              type: MaterialType.transparency,
              child: Text(
                ' $timestring',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  //shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
