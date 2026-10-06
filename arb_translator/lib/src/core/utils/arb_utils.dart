/// Placeholder names used by an ARB message, ICU `plural` / `select` arguments included.
///
/// `{name}` is a placeholder. In `{count, plural, =1{segment} other{{count} segments}}`
/// `count` is the argument and the case bodies are messages of their own, so `segment`
/// is text, not a placeholder. Unbalanced braces never throw; parsing stops at the end.
Set<String> extractPlaceholdersFromText(String s) => (_MessageScanner(s)..message(nested: false)).names;

bool placeholdersMatch({required Set<String> english, required Set<String> target}) =>
    english.length == target.length && english.containsAll(target);

class _MessageScanner {
  _MessageScanner(this._s);

  static final _name = RegExp(r'^[a-zA-Z0-9_]+$');
  static const _selectors = {'plural', 'select', 'selectordinal'};

  final String _s;
  final names = <String>{};
  var _i = 0;

  bool get _atEnd => _i >= _s.length;

  /// Text with arguments; a nested message ends at its unmatched `}`, which is consumed.
  void message({required bool nested}) {
    while (!_atEnd) {
      final c = _s[_i++];
      if (c == '{') _argument();
      if (c == '}' && nested) return;
    }
  }

  /// After `{`: `name}`, or `name, plural|select|selectordinal, cases}`.
  void _argument() {
    final name = _readUntil(const {',', '}', '{'});
    if (_atEnd || _s[_i] == '{') return;
    if (_s[_i++] == '}') {
      _add(name);
      return;
    }
    final type = _readUntil(const {',', '}', '{'});
    if (_atEnd || _s[_i] != ',' || !_selectors.contains(type)) {
      message(nested: true);
      return;
    }
    _add(name);
    _i++;
    while (!_atEnd) {
      _readUntil(const {'{', '}'}); // the case selector, e.g. `=1` or `other`
      if (_atEnd || _s[_i++] == '}') return;
      message(nested: true);
    }
  }

  String _readUntil(Set<String> stops) {
    final start = _i;
    while (!_atEnd && !stops.contains(_s[_i])) {
      _i++;
    }
    return _s.substring(start, _i).trim();
  }

  void _add(String name) {
    if (_name.hasMatch(name)) names.add(name);
  }
}
