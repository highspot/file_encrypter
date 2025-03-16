import 'package:file_encrypter_example/utils/video_util.dart';
import 'package:file_encrypter_example/utils/videos.dart';
import 'package:file_encrypter_example/widgets/crypt_button_group.dart';
import 'package:flutter/material.dart';

class VideoFooter extends StatefulWidget {
  const VideoFooter({required this.video, required this.onDownload, super.key});

  final Video video;
  final VoidCallback onDownload;

  @override
  State<VideoFooter> createState() => _VideoFooterState();
}

class _VideoFooterState extends State<VideoFooter> {
  bool _isDownloaded = false;

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
                  widget.video.subtitle,
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
                onEncrypt: print,
                onDecrypt: print,
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
}
