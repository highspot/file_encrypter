import 'package:file_encrypter_example/utils/videos.dart';
import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({required this.video, super.key});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _Thumbnail(source: video.thumbSource),
          _VideoFooter(video: video),
        ],
      ),
    );
  }
}

class _VideoFooter extends StatelessWidget {
  const _VideoFooter({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final borderSide = BorderSide(
      color: Theme.of(context).colorScheme.primaryContainer,
      width: 2,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: borderSide, right: borderSide, bottom: borderSide),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
                Text(
                  video.subtitle,
                  style: textTheme.labelSmall!.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton.filledTonal(
              onPressed: () {},
              icon: Icon(Icons.file_download),
              iconSize: 20,
              color: colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(source, fit: BoxFit.fitWidth),
    );
  }
}
