import 'package:file_encrypter_example/utils/video_util.dart';
import 'package:file_encrypter_example/utils/videos.dart';
import 'package:file_encrypter_example/widgets/crypt_button_group.dart';
import 'package:flutter/material.dart';

class VideoFooter extends StatefulWidget {
  const VideoFooter({
    required this.video,
    required this.onDownload,
    required this.onPlay,
    super.key,
  });

  final Video video;
  final VoidCallback onDownload;
  final VoidCallback onPlay;

  @override
  State<VideoFooter> createState() => _VideoFooterState();
}

class _VideoFooterState extends State<VideoFooter> {
  bool _isDownloaded = false;
  String _encryptDuration = '';
  String _decryptDuration = '';

  @override
  void initState() {
    super.initState();
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    _isDownloaded = await widget.video.isDownloaded;
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.labelSmall!.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (_isDownloaded)
              CryptButtonGroup(
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
            else
              IconButton.filledTonal(
                tooltip: 'Download Video',
                onPressed: widget.onDownload,
                icon: Icon(Icons.file_download_outlined),
                color: colorScheme.tertiary,
                iconSize: 20,
              ),
          ],
        ),
      ),
    );
  }

  String get subtitle {
    if (_encryptDuration.isEmpty) return widget.video.subtitle;

    if (_decryptDuration.isEmpty) return 'Enc. in $_encryptDuration';

    return 'Enc. in $_encryptDuration; Dec. in $_decryptDuration';
  }
}
