import 'dart:math';
import 'dart:typed_data' show Uint8List;

import 'package:meta/meta.dart' show isTest, visibleForTesting;
import 'package:request_builder/request_builder.dart';
import 'package:test/test.dart';

part 'fixture_provider.dart';
part 'response_expect.dart';
part 'tester.dart';

typedef OnTesterCallback = void Function(RequestBuilderTester tester);

@isTest
void requestBuilderTest(
  Object? description,
  OnTesterCallback body, {
  String? testOn,
  Timeout? timeout,
  Object? skip,
  Object? tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
}) {
  test(
    description,
    () => body(RequestBuilderTester()),
    testOn: testOn,
    timeout: timeout,
    skip: skip,
    tags: tags,
    onPlatform: onPlatform,
    retry: retry,
  );
}
