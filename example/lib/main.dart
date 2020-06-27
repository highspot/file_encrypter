import 'dart:io';

import 'package:file_encrypter/file_encrypter.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: EncryptApp(),
    );
  }
}

String key;

class EncryptApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton.icon(
              onPressed: () async {
                final path = '${(await getApplicationSupportDirectory()).path}/sarbagya.p.download';
                try {
                  await Dio().download(
                    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
                   // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
                   //'http://25.io/toau/audio/sample.txt',
                    path,
                    onReceiveProgress: (s, t) {
                      print((s / t).toStringAsFixed(2));
                    },
                    options: Options(receiveTimeout: 0, followRedirects: true, receiveDataWhenStatusError: true),
                  );
                } catch (e) {
                  print(e);
                }
                print('FILE SIZE: ${File(path).statSync().size/1024/1024} MB');
                final s = Stopwatch()..start();
                key = await FileEncrypter.encrypt(
                  inFilename: '${(await getApplicationSupportDirectory()).path}/sarbagya.p.download',
                  outFileName: '${(await getApplicationSupportDirectory()).path}/sarbagya.dat',
                );
                print('KEY: $key');
                print('ENCRYPTION: Completed in ${s.elapsedMilliseconds} ms');
              },
              icon: Icon(Icons.cloud_download),
              label: Text('Download & Encrypt'),
            ),
            RaisedButton.icon(
              onPressed: () async {
                final s = Stopwatch()..start();
                await FileEncrypter.decrypt(
                  key: key,
                  inFilename: '${(await getApplicationSupportDirectory()).path}/sarbagya.dat',
                  outFileName: '${(await getApplicationSupportDirectory()).path}/podcast.dat',
                );
                print('DECRYPTION: Completed in ${s.elapsedMilliseconds} ms');
              },
              icon: Icon(Icons.cloud_download),
              label: Text('Decrypt'),
            ),
          ],
        ),
      ),
    );
  }
}
