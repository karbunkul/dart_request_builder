import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'request_body.dart';

class MultipartForm {
  final _form = _FormData();

  MultipartForm field({required String name, required String value}) {
    _form.fields.add(MapEntry(name, value));

    return this;
  }

  MultipartForm binary({
    required String field,
    required Uint8List bytes,
    String? filename,
    String? contentType,
  }) {
    final file = _MultipartFile(
      bytes: Uint8List.fromList(bytes),
      filename: filename,
      contentType: contentType,
    );
    _form.files.add(MapEntry(field, file));

    return this;
  }

  MultipartForm text({
    required String field,
    required String text,
    String? filename,
  }) {
    final file = _MultipartFile(
      bytes: Uint8List.fromList(utf8.encode(text)),
      filename: filename,
      contentType: 'text/plain',
    );
    _form.files.add(MapEntry(field, file));

    return this;
  }

  Future<RequestBody> done() async {
    return _FormBody(await _form.readAsBytes(), _form.boundary);
  }
}

class _FormBody implements RequestBody {
  final Uint8List bytes;
  final String boundary;

  _FormBody(this.bytes, this.boundary);

  @override
  Future<Uint8List> content() async => bytes;

  @override
  String mimeType() => 'multipart/form-data; boundary=$boundary';
}

class _MultipartFile {
  final Uint8List bytes;
  final String? filename;
  final String? contentType;

  _MultipartFile({required this.bytes, this.filename, this.contentType});
}

class _FormData {
  _FormData() {
    _init();
  }

  static const String _boundaryPrefix = '--rb-boundary-';

  final fields = <MapEntry<String, String>>[];
  final files = <MapEntry<String, _MultipartFile>>[];

  late String _boundary;
  bool get isFinalized => _isFinalized;
  bool _isFinalized = false;

  String get boundary => _boundary;

  void _init() {
    final random = math.Random();
    final seed = random.nextInt(3296169456).toString().padLeft(10, '0');
    _boundary = _boundaryPrefix + seed;
  }

  Stream<List<int>> finalize() {
    if (isFinalized) {
      throw StateError(
        'The FormData has already been finalized. '
        'This typically means you are using '
        'the same FormData in repeated requests.',
      );
    }
    _isFinalized = true;
    final controller = StreamController<List<int>>(sync: false);
    void write(String string) => controller.add(utf8.encode(string));
    void writeLine() => controller.add([13, 10]);
    void writeBoundary() => write('--$boundary\r\n');

    /// fields
    for (final entry in fields) {
      writeBoundary();
      write(_headerForField(entry.key, entry.value));
      write(entry.value);
      writeLine();
    }

    /// files
    for (final file in files) {
      writeBoundary();
      write(_headerForFile(file));
      controller.add(file.value.bytes);
      writeLine();
    }

    writeBoundary();
    controller.close();

    return controller.stream;
  }

  String _headerForField(String name, String value) {
    final encodeName = _browserEncode(name);

    return 'Content-Disposition: form-data; name="$encodeName"\r\n\r\n';
  }

  String _headerForFile(MapEntry<String, _MultipartFile> entry) {
    final file = entry.value;
    String header = 'Content-Disposition'
        ': form-data; name="${_browserEncode(entry.key)}"';
    if (file.filename != null) {
      header = '$header; filename="${_browserEncode(file.filename)}"';
    }
    header = '$header\r\ncontent-type: ${file.contentType}';

    return '$header\r\n\r\n';
  }

  String? _browserEncode(String? value) {
    if (value == null) {
      return null;
    }
    final pattern = RegExp(r'\r\n|\r|\n');
    return value.replaceAll(pattern, '%0D%0A').replaceAll('"', '%22');
  }

  Future<Uint8List> readAsBytes() {
    return finalize().reduce((a, b) => [...a, ...b]).then(Uint8List.fromList);
  }
}
