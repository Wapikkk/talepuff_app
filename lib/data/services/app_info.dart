import 'package:package_info_plus/package_info_plus.dart';

abstract class AppInfo {
  Future<String> versionLabel();
  Future<String> versionCode();
}

class PackageInfoAppInfo implements AppInfo {
  Future<PackageInfo>? _info;

  Future<PackageInfo> get _loaded => _info ??= PackageInfo.fromPlatform();

  @override
  Future<String> versionLabel() async {
    final info = await _loaded;
    return info.buildNumber.isEmpty ? info.version : '${info.version} (${info.buildNumber})';
  }

  @override
  Future<String> versionCode() async {
    final info = await _loaded;
    return info.buildNumber.isEmpty ? info.version : '${info.version}+${info.buildNumber}';
  }
}
