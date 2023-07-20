typedef OnQueryChanged = void Function(String query, String value);

class QueryManager {
  final OnQueryChanged onQueryChanged;

  const QueryManager(this.onQueryChanged);
}
