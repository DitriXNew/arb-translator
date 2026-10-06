/// Placeholder names used by an ARB message, ICU arguments included.
///
/// `{name}` is a placeholder. In `{count, plural, =1{segment} other{{count} segments}}`
/// `count` is the argument and the case bodies are messages of their own, so `segment`
/// is text, not a placeholder; `{when, date, ::yMMMd}` uses `when`. Unbalanced braces never
/// throw; parsing stops at the end.
///
/// This is gen-l10n's default syntax (`use-escaping: false`): quotes are text, so `'{name}'`
/// is still a placeholder. Projects that turn quoting on are not supported.
Set<String> extractPlaceholdersFromText(String s) => (_MessageScanner(s)..message(nested: false)).names;

/// Whether every `{` in [s] is closed and no `}` is left over, ICU cases included.
///
/// A translation can carry the right placeholders and still be unusable: an unclosed
/// `{count, plural, ...` names `count` but does not compile. This checks balance only, not the
/// rest of ICU syntax: `{count, plural,}` is balanced.
bool hasBalancedBraces(String s) => !(_MessageScanner(s)..message(nested: false)).malformed;

bool placeholdersMatch({required Set<String> english, required Set<String> target}) =>
    english.length == target.length && english.containsAll(target);

class _MessageScanner {
  _MessageScanner(this._s);

  static final _name = RegExp(r'^[a-zA-Z0-9_]+$');
  static const _selectors = {'plural', 'select', 'selectordinal'};

  final String _s;
  final names = <String>{};
  bool malformed = false;
  var _i = 0;

  bool get _atEnd => _i >= _s.length;

  /// Text with arguments; a nested message ends at its unmatched `}`, which is consumed.
  void message({required bool nested}) {
    while (!_atEnd) {
      final c = _s[_i++];
      if (c == '{') _argument();
      if (c == '}') {
        if (nested) return;
        malformed = true;
      }
    }
    if (nested) malformed = true;
  }

  /// After `{`: `name}`, `name, type, style}` (e.g. `date, ::yMMMd`) or
  /// `name, plural|select|selectordinal, cases}`. The name is a placeholder in every form.
  void _argument() {
    final name = _readUntil(const {',', '}', '{'});
    if (_atEnd || _s[_i] == '{') {
      malformed = true;
      return;
    }
    _add(name);
    if (_s[_i++] == '}') return;
    final type = _readUntil(const {',', '}', '{'});
    if (_atEnd || _s[_i] != ',' || !_selectors.contains(type)) {
      message(nested: true);
      return;
    }
    _i++;
    while (!_atEnd) {
      _readUntil(const {'{', '}'}); // the case selector, e.g. `=1` or `other`
      if (_atEnd) break;
      if (_s[_i++] == '}') return;
      message(nested: true);
    }
    malformed = true;
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
