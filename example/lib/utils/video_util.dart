import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_encrypter_example/utils/videos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

typedef DownloadProgressCallback = void Function(int received, int total);

Future<String> get storageDir async {
  Directory? dir;

  if (Platform.isAndroid) dir = await getExternalStorageDirectory();
  dir ??= await getApplicationDocumentsDirectory();

  return dir.path;
}

extension VideoUtil on Video {
  Future<String?> download({
    required DownloadProgressCallback onProgress,
  }) async {
    try {
      await _dio.download(
        source,
        _downloadPath,
        onReceiveProgress: onProgress,
        options: Options(
          receiveTimeout: Duration.zero,
          followRedirects: true,
          receiveDataWhenStatusError: true,
        ),
      );
      return null;
    } on DioException catch (e) {
      return e.message;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String> get _downloadPath async {
    final tempDir = await getTemporaryDirectory();
    return p.join(tempDir.path, fileName, '.download');
  }

  Future<bool> get isDownloaded async {
    return File(await _downloadPath).exists();
  }

  Future<String> get size async {
    final stat = await File(await _downloadPath).stat();
    return '${stat.size / 1024 / 1024} MB';
  }
}

final _dio = Dio();
