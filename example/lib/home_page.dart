import 'package:file_encrypter_example/utils/videos.dart';
import 'package:file_encrypter_example/widgets/video_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Encrypter Demo')),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (_, index) {
          return VideoCard(video: videos[index]);
        },
        separatorBuilder: (_, _) => const SizedBox(height: 16),
      ),
    );
  }
}
