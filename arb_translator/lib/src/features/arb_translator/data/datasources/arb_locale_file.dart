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
  /// Other attributes of `@key` are kept. A new key goes before the first existing key that
  /// sorts after it, so a sorted file stays sorted. Setting what is already there is no change.
  void setTranslation(String key, String text, {required String? sourceHash}) {
    final oldMeta = _data['@$key'];
    final meta = <String, dynamic>{if (oldMeta is Map) ...Map<String, dynamic>.from(oldMeta)};
    if (sourceHash == null) {
      meta.remove('sourceHash');
    } else {
      meta['sourceHash'] = sourceHash;
    }
    final oldHash = oldMeta is Map ? oldMeta['sourceHash'] : null;
    if (_data[key] == text && oldHash == sourceHash) return;

    final isNew = !_data.containsKey(key);
    final rebuilt = <String, dynamic>{};
    var placed = false;
    void place() {
      rebuilt[key] = text;
      if (meta.isNotEmpty) rebuilt['@$key'] = meta;
      placed = true;
    }

    for (final MapEntry(key: k, value: v) in _data.entries) {
      if (k == key || k == '@$key') {
        if (!placed) place();
        continue;
      }
      if (!placed && isNew && !k.startsWith('@') && k.compareTo(key) > 0) place();
      rebuilt[k] = v;
    }
    if (!placed) place();
    _replaceWith(rebuilt);
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

  void _replaceWith(Map<String, dynamic> rebuilt) {
    _data
      ..clear()
      ..addAll(rebuilt);
    _changed = true;
  }
}
