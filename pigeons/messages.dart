// Copyright 2025 Acme Software LLC. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    input: 'pigeons/messages.dart',
    kotlinOut:
        'android/src/main/kotlin/np/com/sarbagyastha/file_encrypter/Messages.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.acmesoftware.file_encrypter',
      errorClassName: 'FileEncrypterError',
    ),
    swiftOut: 'ios/Classes/Messages.swift',
    dartOut: 'lib/src/messages.g.dart',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi()
abstract class FileEncrypterApi {
  @async
  String encrypt(String inFileName, String outFileName);

  @async
  void decrypt(String key, String inFileName, String outFileName);
}
