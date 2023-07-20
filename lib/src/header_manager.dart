typedef OnHeaderChanged = void Function(String header, String value);

class HeaderManager {
  final OnHeaderChanged onHeaderChanged;

  const HeaderManager(this.onHeaderChanged);

  void userAgent(String agent) => onHeaderChanged('user-agent', agent);
}
