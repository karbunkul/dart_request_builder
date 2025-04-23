import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:request_builder/request_builder.dart';
import 'package:test/test.dart';

@isTest
void main() {
  group('ResponseExpect', () {
    test('should pass when status code is 200', () {
      final response = RequestResponse(
        request: _fakeRequest(),
        statusCode: 200,
        bytes: Uint8List(0),
        headers: [],
      );
      final expector = ResponseExpect(response);
      expector.isStatusCode(200);
    });

    test('should fail when status code does not match', () {
      final response = RequestResponse(
        request: _fakeRequest(),
        statusCode: 404,
        bytes: Uint8List(0),
        headers: [],
      );
      final expector = ResponseExpect(response);
      expect(
        () => expector.isStatusCode(200),
        throwsA(predicate((e) => e.toString().contains('invalid status code'))),
      );
    });

    test('should pass when hasBody is true', () {
      final context = _fakeRequest(body: JsonBody({'foo': 'bar'}));
      final response = RequestResponse(
        request: context,
        statusCode: 200,
        bytes: Uint8List(0),
        headers: [],
      );
      ResponseExpect(response).hasBody();
    });

    test('should fail when hasBody is false', () {
      final context = _fakeRequest(hasBody: false);
      final response = RequestResponse(
        request: context,
        statusCode: 200,
        bytes: Uint8List(0),
        headers: [],
      );
      expect(
        () => ResponseExpect(response).hasBody(),
        throwsA(predicate((e) => e.toString().contains('missing body'))),
      );
    });

    test('should pass on valid query param presence', () {
      final uri = Uri.parse('https://example.com?q=test');
      final context = _fakeRequest(uri: uri);
      final response = RequestResponse(
        request: context,
        statusCode: 200,
        bytes: Uint8List(0),
        headers: [],
      );
      ResponseExpect(response).hasQuery('q');
    });

    test('should fail on missing query param', () {
      final uri = Uri.parse('https://example.com');
      final context = _fakeRequest(uri: uri);
      final response = RequestResponse(
        request: context,
        statusCode: 200,
        bytes: Uint8List(0),
        headers: [],
      );
      expect(
        () => ResponseExpect(response).hasQuery('id'),
        throwsA(predicate(
            (e) => e.toString().contains('missing required query parameter'))),
      );
    });

    test('should pass on header match', () {
      final context =
          _fakeRequest(headers: {'content-type': 'application/json'});
      final response = RequestResponse(
        request: context,
        statusCode: 200,
        bytes: Uint8List(0),
        headers: [],
      );
      ResponseExpect(response)
          .hasHeader('content-type', value: 'application/json');
    });

    test('should fail on wrong header value', () {
      final context = _fakeRequest(headers: {'content-type': 'text/html'});
      final response = RequestResponse(
        request: context,
        statusCode: 200,
        bytes: Uint8List(0),
        headers: [],
      );
      expect(
        () => ResponseExpect(response)
            .hasHeader('content-type', value: 'application/json'),
        throwsA(predicate(
            (e) => e.toString().contains('invalid value for header'))),
      );
    });

    test('should use hasHeader internally for content-type', () {
      final context =
          _fakeRequest(headers: {'content-type': 'application/json'});
      final response = RequestResponse(
        request: context,
        statusCode: 200,
        bytes: Uint8List(0),
        headers: [],
      );
      ResponseExpect(response).hasContentType('application/json');
    });
  });
}

RequestContext _fakeRequest({
  bool hasBody = false,
  Uri? uri,
  Map<String, String> headers = const {},
  RequestBody? body,
}) {
  return RequestContext(
    method: 'GET',
    uri: uri ?? Uri.parse('https://example.com'),
    headers: headers.map((k, v) => MapEntry(k.toLowerCase(), v)),
    platform: PlatformType.web,
    body: body,
  );
}
