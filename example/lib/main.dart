import 'package:file_encrypter_example/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EncrypterApp());
}

class EncrypterApp extends StatelessWidget {
  const EncrypterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Encrypter Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.amber,
        scaffoldBackgroundColor: Colors.white,
        progressIndicatorTheme: ProgressIndicatorThemeData(year2023: false),
      ),
      home: const HomePage(),
    );
  }
}

// class _EncrypterAppState extends State<EncrypterApp> {
//   String _encryptionKey = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView.separated(
//         padding: EdgeInsets.all(16),
//         itemCount: videos.length,
//         itemBuilder: (_, index) {
//           return VideoCard(video: videos[index]);
//         },
//         separatorBuilder: (_, _) => const SizedBox(height: 16),
//       ),
//     );
//
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton.icon(
//             onPressed: () async {
//               final path = await getFilePath('sarbagya.p.download');
//               try {
//                 await Dio().download(
//                   'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
//                   // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
//                   //'http://25.io/toau/audio/sample.txt',
//                   path,
//                   onReceiveProgress: (s, t) {
//                     debugPrint((s / t).toStringAsFixed(2));
//                   },
//                   options: Options(
//                     receiveTimeout: Duration.zero,
//                     followRedirects: true,
//                     receiveDataWhenStatusError: true,
//                   ),
//                 );
//               } catch (e) {
//                 debugPrint(e.toString());
//               }
//               debugPrint(
//                 'FILE SIZE: ${File(path).statSync().size / 1024 / 1024} MB',
//               );
//               final s = Stopwatch()..start();
//               _encryptionKey = await FileEncrypter.encrypt(
//                 inFileName: await getFilePath('sarbagya.p.download'),
//                 outFileName: await getFilePath('sarbagya.dat'),
//               );
//               debugPrint('KEY: $_encryptionKey');
//               debugPrint(
//                 'ENCRYPTION: Completed in ${s.elapsedMilliseconds} ms',
//               );
//             },
//             icon: Icon(Icons.cloud_download),
//             label: Text('Download & Encrypt'),
//           ),
//           ElevatedButton.icon(
//             onPressed: () async {
//               final s = Stopwatch()..start();
//               await FileEncrypter.decrypt(
//                 key: _encryptionKey,
//                 inFileName: await getFilePath('sarbagya.dat'),
//                 outFileName: await getFilePath('podcast.mp4'),
//               );
//               debugPrint(
//                 'DECRYPTION: Completed in ${s.elapsedMilliseconds} ms',
//               );
//             },
//             icon: Icon(Icons.cloud_download),
//             label: Text('Decrypt'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<String> getFilePath(String name) async {
//     final dir = await getApplicationSupportDirectory();
//     return '${dir.path}/$name';
//   }
// }
