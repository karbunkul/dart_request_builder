import 'dart:convert';

import 'package:request_builder/request_builder.dart';
import 'package:test/test.dart';

void main() {
  group('FixtureProvider', () {
    test('returns default 200 response with empty body and headers', () async {
      final provider = FixtureProvider();
      final response = await provider.request(_fakeRequest());

      expect(response.statusCode, equals(200));
      expect(response.bytes, isEmpty);
      expect(response.headers, isEmpty);
    });

    test('applies status code override', () async {
      final provider = FixtureProvider();
      provider.updateStatusCode(404);

      final response = await provider.request(_fakeRequest());
      expect(response.statusCode, equals(404));
    });

    test('sets response content from bytes', () async {
      final provider = FixtureProvider();
      provider.updateContentFromBytes([1, 2, 3]);

      final response = await provider.request(_fakeRequest());
      expect(response.bytes, equals([1, 2, 3]));
    });

    test('sets response content from text', () async {
      final provider = FixtureProvider();
      provider.updateContentFromText('hello');

      final response = await provider.request(_fakeRequest());
      expect(utf8.decode(response.bytes), equals('hello'));
    });

    test('sets response content from JSON', () async {
      final provider = FixtureProvider();
      provider.updateContentFromJson({'foo': 'bar'});

      final response = await provider.request(_fakeRequest());
      final json =
          jsonDecode(utf8.decode(response.bytes)) as Map<String, dynamic>;
      expect(json['foo'], equals('bar'));
    });

    test('sets response headers correctly', () async {
      final provider = FixtureProvider();
      provider.updateHeaders({'content-type': 'application/json'});

      final response = await provider.request(_fakeRequest());
      expect(response.headers.length, equals(1));
      expect(response.headers.first.name, equals('content-type'));
      expect(response.headers.first.values.first, equals('application/json'));
    });

    test('applies artificial delay', () async {
      final provider = FixtureProvider();
      provider.simulateResponseDelay(Duration(milliseconds: 50));

      final sw = Stopwatch()..start();
      await provider.request(_fakeRequest());
      sw.stop();

      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(50));
    });
  });
}

RequestContext _fakeRequest() {
  return RequestContext(
    method: 'GET',
    uri: Uri.parse('https://example.com'),
    headers: {},
    platform: PlatformType.web,
  );
}
