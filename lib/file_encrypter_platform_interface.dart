import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'file_encrypter_method_channel.dart';

abstract class FileEncrypterPlatform extends PlatformInterface {
  /// Constructs a FileEncrypterPlatform.
  FileEncrypterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FileEncrypterPlatform _instance = MethodChannelFileEncrypter();

  /// The default instance of [FileEncrypterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFileEncrypter].
  static FileEncrypterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FileEncrypterPlatform] when
  /// they register themselves.
  static set instance(FileEncrypterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
