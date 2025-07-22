import 'dart:developer';

import 'package:file_encrypter/file_encrypter.dart';
import 'package:file_encrypter_example/utils/videos.dart';
import 'package:flutter/material.dart';

import 'package:file_encrypter_example/utils/video_util.dart';

typedef CryptCallback = void Function(String duration);

class CryptButtonGroup extends StatefulWidget {
  const CryptButtonGroup({
    required this.video,
    required this.onEncrypt,
    required this.onDecrypt,
    super.key,
  });

  final Video video;
  final CryptCallback onEncrypt;
  final CryptCallback onDecrypt;

  @override
  State<CryptButtonGroup> createState() => _CryptButtonGroupState();
}

class _CryptButtonGroupState extends State<CryptButtonGroup> {
  String _decryptKey = '';
  bool _encrypting = false;
  bool _decrypting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final encrypted = _decryptKey.isNotEmpty;

    final encryptButton = IconButton.filledTonal(
      tooltip: encrypted ? 'Protected' : 'Protect Video',
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.error,
        disabledBackgroundColor: Color(0xFFD6F5D6),
        disabledForegroundColor: Colors.green,
      ),
      onPressed: encrypted ? null : _encrypt,
      icon: Icon(encrypted ? Icons.lock_outline : Icons.no_encryption_outlined),
      iconSize: 20,
    );

    return AnimatedCrossFade(
      firstChild: _encrypting
          ? Padding(
              padding: const EdgeInsets.all(4),
              child: _LoadingIndicator(),
            )
          : encryptButton,
      secondChild: Row(
        children: [
          encryptButton,
          const SizedBox(width: 10),
          _decrypting
              ? _LoadingIndicator()
              : IconButton.filledTonal(
                  onPressed: _decrypt,
                  icon: Icon(Icons.play_arrow),
                  color: colorScheme.tertiary,
                ),
        ],
      ),
      crossFadeState: encrypted ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  Future<String> _filePath({String suffix = ''}) async {
    final storageDirectory = await storageDir;
    return '$storageDirectory/${widget.video.fileName}$suffix';
  }

  Future<void> _encrypt() async {
    _encrypting = true;
    setState(() {});
    final watch = Stopwatch()..start();

    final inFileName = await widget.video.downloadPath;
    final outFileName = await _filePath(suffix: '.enc');
    log('Encrypting $inFileName to $outFileName', name: 'FileEncrypter');

    _decryptKey = await FileEncrypter.encrypt(
      inFileName: inFileName,
      outFileName: outFileName,
    );

    widget.onEncrypt('${watch.elapsedMilliseconds} ms');
    _encrypting = false;
    watch.stop();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _decrypt() async {
    _decrypting = true;
    setState(() {});
    final watch = Stopwatch()..start();

    final inFileName = await _filePath(suffix: '.enc');
    final outFileName = await _filePath();
    log('Decrypting $inFileName to $outFileName', name: 'FileEncrypter');

    await FileEncrypter.decrypt(
      inFileName: await _filePath(suffix: '.enc'),
      outFileName: await _filePath(),
      key: _decryptKey,
    );

    widget.onDecrypt('${watch.elapsedMilliseconds} ms');
    _decrypting = false;
    watch.stop();
    if (!mounted) return;
    setState(() {});
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
      ),
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        color: colorScheme.tertiary,
        strokeWidth: 2,
      ),
    );
  }
}
