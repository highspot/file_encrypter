// Copyright 2025 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    input: 'pigeons/messages.dart',
    kotlinOut:
        'android/src/main/kotlin/io/flutter/plugins/sharedpreferences/MessagesAsync.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.sharedpreferences',
      errorClassName: 'SharedPreferencesError',
    ),
    dartOut: 'lib/src/messages_async.g.dart',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi()
abstract class FileEncrypterApi {
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  String encrypt(String inFilename, String outFileName);

  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void decrypt(String key, String inFilename, String outFileName);
}
