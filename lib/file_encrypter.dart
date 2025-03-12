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
