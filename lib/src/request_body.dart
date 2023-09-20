import 'dart:convert';
import 'dart:typed_data';

abstract interface class RequestBody {
  String mimeType();
  Future<Uint8List> content();
}

class JsonBody implements RequestBody {
  final Map<String, dynamic> json;

  const JsonBody(this.json);

  @override
  String mimeType() => 'application/json; charset=utf-8';

  @override
  Future<Uint8List> content() async {
    return Uint8List.fromList(utf8.encode(jsonEncode(json)));
  }
}

class TextBody implements RequestBody {
  final String text;

  const TextBody(this.text);

  @override
  String mimeType() => 'text/plain';

  @override
  Future<Uint8List> content() async {
    return Uint8List.fromList(utf8.encode(text));
  }
}
