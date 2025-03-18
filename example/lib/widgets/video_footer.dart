import 'package:file_encrypter_example/utils/video_util.dart';
import 'package:file_encrypter_example/utils/videos.dart';
import 'package:file_encrypter_example/widgets/crypt_button_group.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VideoFooter extends StatefulWidget {
  const VideoFooter({
    required this.video,
    required this.onDownload,
    required this.onPlay,
    super.key,
  });

  final Video video;
  final AsyncCallback onDownload;
  final VoidCallback onPlay;

  @override
  State<VideoFooter> createState() => _VideoFooterState();
}

class _VideoFooterState extends State<VideoFooter> {
  bool _isDownloaded = false;
  String _encryptDuration = '';
  String _decryptDuration = '';
  String _videoSize = '';

  @override
  void initState() {
    super.initState();
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    _isDownloaded = await widget.video.isDownloaded;
    if (_isDownloaded) _videoSize = await widget.video.size;
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final borderSide = BorderSide(
      color: Theme.of(context).colorScheme.primaryContainer,
      width: 1,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: borderSide, right: borderSide, bottom: borderSide),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall!.copyWith(
                      color: colorScheme.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: textTheme.labelSmall!.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 106,
              alignment: Alignment.centerRight,
              child:
                  _isDownloaded
                      ? CryptButtonGroup(
                        video: widget.video,
                        onEncrypt: (duration) {
                          _encryptDuration = duration;
                          setState(() {});
                        },
                        onDecrypt: (duration) {
                          _decryptDuration = duration;
                          setState(() {});

                          widget.onPlay();
                        },
                      )
                      : IconButton.filledTonal(
                        tooltip: 'Download Video',
                        onPressed: () async {
                          await widget.onDownload();
                          _checkDownloaded();
                        },
                        icon: Icon(Icons.file_download_outlined),
                        color: colorScheme.tertiary,
                        iconSize: 20,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  String get title {
    if (_videoSize.isEmpty) return widget.video.title;

    return '[$_videoSize] ${widget.video.title}';
  }

  String get subtitle {
    if (_encryptDuration.isEmpty) return widget.video.subtitle;

    if (_decryptDuration.isEmpty) return 'Enc. in $_encryptDuration';

    return 'Enc. in $_encryptDuration; Dec. in $_decryptDuration';
  }
}
