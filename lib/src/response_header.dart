final class ResponseHeader {
  final String name;
  final List<String> values;

  ResponseHeader({required this.name, required this.values});

  bool get isMultiple => values.length > 1;

  String get value => isMultiple ? values.join(', ') : values.first;

  @override
  String toString() => '(name=$name value=$value)';
}
