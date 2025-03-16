import 'dart:io';
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:file_encrypter_example/utils/video_util.dart';
import 'package:file_encrypter_example/utils/videos.dart';
import 'package:file_encrypter_example/widgets/video_footer.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({required this.video, super.key});

  final Video video;

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  ChewieController? _chewieController;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final player =
        _chewieController == null
            ? Image.network(widget.video.thumbSource, fit: BoxFit.fitWidth)
            : Chewie(controller: _chewieController!);

    return Material(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Stack(
        children: [
          Column(
            children: [
              AspectRatio(aspectRatio: 16 / 9, child: player),
              VideoFooter(
                video: widget.video,
                onDownload: _onDownload,
                onPlay: _onPlay,
              ),
            ],
          ),
          if (_progress > 0 && _progress < 1)
            Positioned.fill(child: _ProgressOverlay(progress: _progress)),
        ],
      ),
    );
  }

  Future<void> _onDownload() async {
    _updateProgress(.001);
    await widget.video.download(
      onProgress: (received, total) {
        _updateProgress(received / total);
      },
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _onPlay() async {
    final videoPlayerController = VideoPlayerController.file(
      File('${await storageDir}/${widget.video.fileName}'),
    );

    await videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
    );
    if (!mounted) return;
    setState(() {});
  }

  void _updateProgress(double progress) {
    _progress = progress;
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        color: Theme.of(context).colorScheme.surface.withAlpha(40),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: LinearProgressIndicator(value: progress),
      ),
    );
  }
}
