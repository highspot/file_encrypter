import 'dart:ui';

import 'package:file_encrypter_example/utils/video_util.dart';
import 'package:file_encrypter_example/utils/videos.dart';
import 'package:file_encrypter_example/widgets/video_footer.dart';
import 'package:flutter/material.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({required this.video, super.key});

  final Video video;

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Stack(
        children: [
          Column(
            children: [
              _Thumbnail(source: widget.video.thumbSource),
              VideoFooter(
                video: widget.video,
                onDownload: () async {
                  _updateProgress(.001);
                  await widget.video.download(
                    onProgress: (received, total) {
                      _updateProgress(received / total);
                    },
                  );

                  if (!mounted) return;
                  setState(() {});
                },
                onPlay: () {},
              ),
            ],
          ),
          if (_progress > 0 && _progress < 1)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: Theme.of(context).colorScheme.surface.withAlpha(40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: LinearProgressIndicator(value: _progress),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _updateProgress(double progress) {
    _progress = progress;
    if (!mounted) return;
    setState(() {});
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
