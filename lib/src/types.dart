import 'dart:isolate';

import 'package:meta/meta.dart';

@internal
typedef Json = Map<String, dynamic>;
typedef ImportCallback<T> = T Function(Json json);
typedef IsolateEntryPointCallback = Function(SendPort sendPort);

enum PlatformType {
  web('web'),
  ios('ios'),
  android('android'),
  linux('linux'),
  windows('windows'),
  mac('mac');

  final String platform;

  const PlatformType(this.platform);

  bool get isMobile => this == ios || this == android;

  bool get isDesktop => this == mac || this == windows || this == linux;

  bool get isWeb => this == web;

  @override
  String toString() => platform;
}
