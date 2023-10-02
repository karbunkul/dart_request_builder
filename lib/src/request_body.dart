import 'dart:convert';
import 'dart:typed_data';

enum BodySourceType { string, binary }

abstract base class RequestBody {
  const RequestBody();
  String mimeType();
  Future<Uint8List> content();

  BodySourceType get sourceType => BodySourceType.string;
}

final class JsonBody extends RequestBody {
  final Map<String, dynamic> json;

  const JsonBody(this.json);

  @override
  String mimeType() => 'application/json; charset=utf-8';

  @override
  Future<Uint8List> content() async {
    return Uint8List.fromList(utf8.encode(jsonEncode(json)));
  }
}

final class TextBody extends RequestBody {
  final String text;

  const TextBody(this.text);

  @override
  String mimeType() => 'text/plain';

  @override
  Future<Uint8List> content() async {
    return Uint8List.fromList(utf8.encode(text));
  }
}
