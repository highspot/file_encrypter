// Copyright 2025 Acme Software LLC. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_encrypter/src/messages.g.dart';

class FileEncrypter {
  static Future<String> encrypt({
    required String inFileName,
    required String outFileName,
  }) async {
    return FileEncrypterApi().encrypt(inFileName, outFileName);
  }

  static Future<void> decrypt({
    required String key,
    required String inFileName,
    required String outFileName,
  }) async {
    return FileEncrypterApi().decrypt(key, inFileName, outFileName);
  }
}
