class ResponseDecodeError extends Error {
  final String source;
  ResponseDecodeError(this.source);

  @override
  String toString() => 'ResponseDecodeError in \n$source';
}

class JsonImportError extends Error {}
