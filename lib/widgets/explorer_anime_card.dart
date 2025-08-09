import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:metia/anilist/anime.dart';

class ExplorerAnimeCard extends StatefulWidget {
  final String tabName;
  final int index;
  final Media anime;
  final VoidCallback? onLibraryChanged;
  final BuildContext context;

  const ExplorerAnimeCard({
    super.key,
    required this.tabName,
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

  @override
  void initState() {
    // TODO: implement initState
    title =
        widget.anime.title.english ??
        widget.anime.title.romaji ??
        widget.anime.title.native ??
        "NO TITLE";
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
                          : widget.anime.averageScore
                                .toString()
                                .replaceRange(1, 1, '.'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
              ),
              Icon(Icons.star, size: 16,color: Colors.orange,),
            ],
          ),
        ],
      ),
    );
  }
}
