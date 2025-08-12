import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:metia/anilist/anime.dart';
import 'package:metia/data/user/profile.dart';
import 'package:metia/data/user/user_library.dart';
import 'package:metia/models/login_provider.dart';
import 'package:metia/tools/general_tools.dart';
import 'package:provider/provider.dart';

class ExplorerAnimeCard extends StatefulWidget {
  final String listName;
  final int index;
  final Media anime;
  final VoidCallback? onLibraryChanged;
  final BuildContext context;
  final bool alreadyInLibrary;

  const ExplorerAnimeCard({
    required this.alreadyInLibrary,
    super.key,
    required this.listName,
    required this.index,
    required this.anime,
    this.onLibraryChanged,
    required this.context,
  });

  @override
  State<ExplorerAnimeCard> createState() => _ExplorerAnimeCardState();
}

class _ExplorerAnimeCardState extends State<ExplorerAnimeCard> {
  late final String title;
  late final Profile user;

  @override
  void initState() {
    // TODO: implement initState
    title =
        widget.anime.title.english ??
        widget.anime.title.romaji ??
        widget.anime.title.native ??
        "NO TITLE";
    Provider.of<UserProvider>(context, listen: false).user;
    super.initState();
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
                  GestureDetector(
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
                              imageUrl: widget.anime.coverImage.extraLarge,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                            Opacity(
                              opacity: widget.alreadyInLibrary ? 0.60 : 0,
                              child: Container(color: Colors.black),
                            ),
                            if (widget.alreadyInLibrary)
                              Center(
                                child: Text(
                                  widget.listName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            if (!widget.alreadyInLibrary)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      MediaListEntry anime = MediaListEntry(
                                        id: 0,
                                        status: "notspecified",
                                        media: widget.anime,
                                      );
                                      anime.setGroup(
                                        MediaListGroup(
                                          color: Colors.white,
                                          name: "notspecified",
                                          entries: [],
                                          isInteractive: false,
                                          isCustom: false,
                                        ),
                                      );
                                      Tools.transferToAnotherList(
                                        anime,
                                        context,
                                        false
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Container(
                                        color: const Color.fromARGB(
                                          121,
                                          255,
                                          255,
                                          255,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${widget.anime.seasonYear}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            ),
          ),
          Row(
            children: [
              Text(
                widget.anime.averageScore == null ||
                        widget.anime.averageScore == 0
                    ? "0.0"
                    : widget.anime.averageScore.toString().replaceRange(
                        1,
                        1,
                        '.',
                      ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
              ),
              Icon(Icons.star, size: 16, color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
}
