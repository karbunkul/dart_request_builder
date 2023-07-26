final class ResponseHeader {
  late final String _name;
  final List<String> values;

  ResponseHeader({required String name, required this.values})
      : _name = name.toLowerCase();

  bool get isMultiple => values.length > 1;

  String get value => isMultiple ? values.join(', ') : values.first;
  String get name => _name;

  @override
  String toString() => '(name=$name value=$value)';
}
