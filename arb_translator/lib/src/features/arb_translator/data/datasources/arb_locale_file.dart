import 'dart:convert';
import 'dart:io';

/// One locale ARB file, edited key by key.
///
/// `ArbFileDataSource.serializeLocale` rebuilds a locale file from entries and keeps only
/// translations and their `sourceHash`. This instead changes just the keys it is told to
/// and leaves the rest of the file as it was: empty values, other `@@` fields, other
/// `@key` attributes, key order, line endings and the trailing newline.
class ArbLocaleFile {
  ArbLocaleFile._(this.file, this._data, {required bool trailingNewline, required bool crlf})
    : _trailingNewline = trailingNewline,
      _crlf = crlf;

  /// Reads [file], or starts an empty one for [locale] when it does not exist yet.
  factory ArbLocaleFile.open(File file, {required String locale}) {
    if (!file.existsSync()) return ArbLocaleFile._(file, {'@@locale': locale}, trailingNewline: false, crlf: false);
    final content = file.readAsStringSync();
    return ArbLocaleFile._(
      file,
      json.decode(content) as Map<String, dynamic>,
      trailingNewline: content.endsWith('\n'),
      crlf: content.contains('\r\n'),
    );
  }

  final File file;
  final Map<String, dynamic> _data;
  final bool _trailingNewline;
  final bool _crlf;
  var _changed = false;

  /// Whether anything was set or removed since the file was read.
  bool get isChanged => _changed;

  /// Sets [key] to [text] and its `sourceHash` attribute to [sourceHash] (removed when null).
  ///
  /// Other attributes of `@key` are kept. An existing key and its `@key` stay where they are;
  /// `@key` added to an existing key goes right after it. A new key goes before the first
  /// existing key that sorts after it, so a sorted file stays sorted. Setting what is already
  /// there is no change.
  void setTranslation(String key, String text, {required String? sourceHash}) {
    final metaKey = '@$key';
    final oldMeta = _data[metaKey];
    final meta = <String, dynamic>{if (oldMeta is Map) ...Map<String, dynamic>.from(oldMeta)};
    if (sourceHash == null) {
      meta.remove('sourceHash');
    } else {
      meta['sourceHash'] = sourceHash;
    }
    final oldHash = oldMeta is Map ? oldMeta['sourceHash'] : null;
    if (_data[key] == text && oldHash == sourceHash) return;
    _changed = true;

    if (_data.containsKey(key)) {
      _data[key] = text;
      if (meta.isEmpty) {
        _data.remove(metaKey);
      } else if (_data.containsKey(metaKey)) {
        _data[metaKey] = meta;
      } else {
        _insert(before: _keyAfter(key), entries: {metaKey: meta});
      }
      return;
    }

    // A stray `@key` without its value moves next to the new value.
    _data.remove(metaKey);
    _insert(
      before: _data.keys.where((k) => !k.startsWith('@')).where((k) => k.compareTo(key) > 0).firstOrNull,
      entries: {key: text, if (meta.isNotEmpty) metaKey: meta},
    );
  }

  /// Removes [key] and its `@key` attributes, whatever the value.
  void remove(String key) {
    if (!_data.containsKey(key) && !_data.containsKey('@$key')) return;
    _data
      ..remove(key)
      ..remove('@$key');
    _changed = true;
  }

  /// The file content: two-space JSON, in the original line endings and trailing newline.
  String encode() {
    var content = const JsonEncoder.withIndent('  ').convert(_data);
    if (_trailingNewline) content += '\n';
    return _crlf ? content.replaceAll('\n', '\r\n') : content;
  }

  Future<void> save() => file.writeAsString(encode());

  /// The key that follows [key] in the file, or null when [key] is last.
  String? _keyAfter(String key) {
    final keys = _data.keys.toList();
    final index = keys.indexOf(key);
    return index + 1 < keys.length ? keys[index + 1] : null;
  }

  /// Inserts [entries] in front of [before], or at the end when it is null.
  void _insert({required String? before, required Map<String, dynamic> entries}) {
    final rebuilt = <String, dynamic>{};
    for (final MapEntry(key: k, value: v) in _data.entries) {
      if (k == before) rebuilt.addAll(entries);
      rebuilt[k] = v;
    }
    if (before == null) rebuilt.addAll(entries);
    _data
      ..clear()
      ..addAll(rebuilt);
  }
}
