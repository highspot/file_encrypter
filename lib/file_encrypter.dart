// Copyright 2025 Acme Software LLC. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_encrypter/src/messages.g.dart';

/// A utility class for encrypting and decrypting files using AES-256 in CBC mode with PKCS5 padding.
/// This class provides static methods to perform encryption and decryption operations on files.
class FileEncrypter {
  /// Encrypts a file using AES-256 in CBC mode with PKCS5 padding.
  ///
  /// This method reads the input file specified by [inFileName], encrypts its contents,
  /// and writes the encrypted data to the output file specified by [outFileName].
  ///
  /// The encryption process generates a base64-encoded secret key, which is returned as a string.
  ///
  /// **Parameters:**
  /// - [inFileName]: The path to the input file to be encrypted.
  /// - [outFileName]: The path where the encrypted output file will be saved.
  ///
  /// **Returns:**
  /// A [Future] that completes with the base64-encoded secret key used for encryption.
  ///
  /// **Usage:**
  /// ```dart
  /// String secretKey = await FileEncrypter.encrypt(
  ///   inFileName: 'path/to/input_file.txt',
  ///   outFileName: 'path/to/encrypted_file.dat',
  /// );
  /// ```
  static Future<String> encrypt({
    required String inFileName,
    required String outFileName,
  }) async {
    return FileEncrypterApi().encrypt(inFileName, outFileName);
  }

  /// Decrypts a file using AES-256 in CBC mode with PKCS5 padding.
  ///
  /// This method reads the encrypted input file specified by [inFileName], decrypts its contents
  /// using the provided [key], and writes the decrypted data to the output file specified by [outFileName].
  ///
  /// **Parameters:**
  /// - [key]: The base64-encoded secret key used for decryption. This key should match the one used during encryption.
  /// - [inFileName]: The path to the encrypted input file to be decrypted.
  /// - [outFileName]: The path where the decrypted output file will be saved.
  ///
  /// **Returns:**
  /// A [Future] that completes when the decryption process is finished.
  ///
  /// **Usage:**
  /// ```dart
  /// await FileEncrypter.decrypt(
  ///   key: 'your_base64_secret_key',
  ///   inFileName: 'path/to/encrypted_file.dat',
  ///   outFileName: 'path/to/decrypted_file.txt',
  /// );
  /// ```
  static Future<void> decrypt({
    required String key,
    required String inFileName,
    required String outFileName,
  }) async {
    return FileEncrypterApi().decrypt(key, inFileName, outFileName);
  }
}
