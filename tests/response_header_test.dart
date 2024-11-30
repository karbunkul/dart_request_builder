import 'package:request_builder/request_builder.dart';
import 'package:test/test.dart';

void main() {
  test('single value', () {
    final header = ResponseHeader(name: 'filename', values: ['test.txt']);
    expect(header.isMultiple, equals(false));
    expect(header.value, equals('test.txt'));
  });

  test('multi value', () {
    final header = ResponseHeader(name: 'filename', values: [
      'test.txt',
      'test.dart',
    ]);
    expect(header.isMultiple, equals(true));
    expect(header.value, equals('test.txt, test.dart'));
  });

  test('convert to int', () {
    final header = ResponseHeader(name: 'filename', values: ['1']);
    expect(header.toInt(), equals(1));
  });

  test('convert to double', () {
    final header = ResponseHeader(name: 'filename', values: ['1']);
    expect(header.toDouble(), equals(1.0));
  });

  test('convert to bool', () {
    var header = ResponseHeader(name: 'filename', values: ['True']);
    expect(header.toBool(), equals(true));
    header = ResponseHeader(name: 'filename', values: ['False']);
    expect(header.toBool(), equals(false));
    header = ResponseHeader(name: 'filename', values: ['true']);
    expect(header.toBool(), equals(true));
  });

  test('case insensitive bool conversion', () {
    var header = ResponseHeader(name: 'enabled', values: ['TRUE']);
    expect(header.toBool(), equals(true));
    header = ResponseHeader(name: 'enabled', values: ['FALSE']);
    expect(header.toBool(), equals(false));
  });

  test('throw exceptions', () {
    final header = ResponseHeader(name: 'filename', values: ['1s']);
    expect(() => header.toInt(), throwsA(isA<FormatException>()));
    expect(() => header.toDouble(), throwsA(isA<FormatException>()));
    expect(() => header.toBool(), throwsA(isA<FormatException>()));
  });

  test('equals', () {
    final a = ResponseHeader(name: 'enabled', values: ['TRUE']);
    final b = ResponseHeader(name: 'enabled', values: ['TRUE']);

    expect(identical(a, b), equals(false));
    expect(a == b, equals(true));
    expect(a.hashCode == b.hashCode, equals(true));
  });
}
