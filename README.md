# 🔐 File Encrypter

[![pub package](https://img.shields.io/pub/vpre/file_encrypter.svg)](https://pub.dartlang.org/packages/file_encrypter)

Super-fast file encryption library for Flutter, utilizing **AES-256** encryption in **CBC mode**
with **PKCS5 padding**. This package is designed to handle large files efficiently. 🚀

## ✨ Features

- 🔒 **AES-256 Encryption**: Secure your files with a strong encryption standard.
- 🔄 **CBC Mode with PKCS5 Padding**: Ensures compatibility and security.
- 📂 **Handles Large Files**: Optimized for encrypting and decrypting big files.
- ⚡ **Chunk-Based Encryption**: Files are encrypted and decrypted in chunks to improve performance
  and support large files efficiently.

## 🚀 Usage

### 🔐 Encrypting a File

```dart
import 'package:file_encrypter/file_encrypter.dart';

void main() async {
  String secretKey = await FileEncrypter.encrypt(
    inFilename: 'open_file.mkv',
    outFileName: 'encrypted_file.dat',
  );

  print('🔒 Encryption complete. Secret key: \$secretKey');
}
```

This will create `encrypted_file.dat`, an encrypted version of `open_file.mkv`. The `secretKey` is a
base64-encoded key generated using a cryptographic random number generator.

### 🔓 Decrypting a File

```dart
import 'package:file_encrypter/file_encrypter.dart';

void main() async {
  String key = 'your_base64_secret_key'; // Use the key from the encryption step

  await FileEncrypter.decrypt(
    key: key,
    inFilename: 'encrypted_file.dat',
    outFileName: 'open_file.mkv',
  );

  print('🔓 Decryption complete.');
}
```

This will restore `open_file.mkv` from `encrypted_file.dat`.

## 📜 License

This project is licensed under the [BSD-3-Clause License](./LICENSE).

---

For more details, visit
the [official package page](https://pub.dartlang.org/packages/file_encrypter).

