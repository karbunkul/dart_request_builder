import 'dart:isolate';

import 'package:meta/meta.dart';

@internal
typedef Json = Map<String, dynamic>;
typedef ImportCallback<T> = T Function(Json json);
typedef IsolateEntryPointCallback = Function(SendPort sendPort);

enum PlatformType {
  web(platform: 'web', supportIsolate: false),
  ios(platform: 'ios', supportIsolate: true),
  android(platform: 'android', supportIsolate: true),
  linux(platform: 'linux', supportIsolate: true),
  windows(platform: 'windows', supportIsolate: true),
  mac(platform: 'mac', supportIsolate: true);

  final String platform;
  final bool supportIsolate;

  const PlatformType({required this.platform, required this.supportIsolate});

  bool get isMobile => this == ios || this == android;

  bool get isDesktop => this == mac || this == windows || this == linux;

  bool get isWeb => this == web;

  @override
  String toString() => platform;
}
