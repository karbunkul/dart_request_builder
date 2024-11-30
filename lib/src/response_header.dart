import 'dart:collection';

final class ResponseHeader {
  late final String _name;
  final List<String> _values;

  ResponseHeader({
    required String name,
    required List<String> values,
  })  : _name = name.toLowerCase(),
        _values = List.unmodifiable(values);

  late final String _value = isMultiple ? _values.join(', ') : _values.first;

  bool get isMultiple => _values.length > 1;
  String get value => _value;
  String get name => _name;

  UnmodifiableListView<String> get values => UnmodifiableListView(_values);

  int toInt() {
    final result = int.tryParse(value);
    if (result == null) {
      throw FormatException(
        'Failed to parse header "$name" with value "$value" as int.',
      );
    }
    return result;
  }

  double toDouble() {
    final result = double.tryParse(value);
    if (result == null) {
      throw FormatException(
        'Failed to parse header "$name" with value "$value" as double.',
      );
    }
    return result;
  }

  bool toBool() {
    final lowerValue = value.toLowerCase();
    if (lowerValue == 'true') return true;
    if (lowerValue == 'false') return false;

    throw FormatException(
      'Failed to parse header "$name" with value "$value" as bool.',
    );
  }

  @override
  int get hashCode => Object.hash(_name, _values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseHeader &&
          runtimeType == other.runtimeType &&
          _name == other._name &&
          _values == other._values;

  @override
  String toString() => '(name=$name value=$value)';
}
