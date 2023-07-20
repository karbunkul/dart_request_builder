import 'dart:convert';
import 'dart:typed_data';

abstract interface class RequestBody {
  String mimeType();
  Uint8List content();
}

class JsonBody implements RequestBody {
  final Map<String, dynamic> json;

  const JsonBody(this.json);

  @override
  String mimeType() => 'application/json; charset=utf-8';

  @override
  Uint8List content() {
    return Uint8List.fromList(utf8.encode(jsonEncode(json)));
  }
}

class TextBody implements RequestBody {
  final String text;

  const TextBody(this.text);

  @override
  String mimeType() => 'text/plain';

  @override
  Uint8List content() {
    return Uint8List.fromList(utf8.encode(text));
  }
}
