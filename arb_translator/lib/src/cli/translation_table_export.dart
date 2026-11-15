import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';

/// File format of `arb_translator_cli --export`.
enum ExportFormat {
  /// A GitHub-flavoured Markdown table.
  md,

  /// RFC 4180 CSV: comma-separated, CRLF line ends, fields quoted when needed.
  csv;

  /// The format a file name implies by its extension, or null.
  static ExportFormat? fromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.md') || lower.endsWith('.markdown')) return md;
    if (lower.endsWith('.csv')) return csv;
    return null;
  }
}

/// Renders translations as one table: a row per key, a column per locale.
class TranslationTableExport {
  const TranslationTableExport._();

  /// Columns: `key`, `description` (from the template's `@key`), [baseLocale], then [locales]
  /// in the order given. A missing translation is an empty cell.
  static String render({
    required ExportFormat format,
    required String baseLocale,
    required List<String> locales,
    required List<TranslationEntry> entries,
  }) {
    final header = ['key', 'description', baseLocale, ...locales];
    final rows = [
      for (final e in entries)
        [e.key, e.meta.description ?? '', e.values[baseLocale] ?? '', for (final l in locales) e.values[l] ?? ''],
    ];
    return switch (format) {
      ExportFormat.md => _markdown(header, rows),
      ExportFormat.csv => _csv(header, rows),
    };
  }

  static String _markdown(List<String> header, List<List<String>> rows) {
    String line(List<String> cells) => '| ${cells.map(_mdCell).join(' | ')} |';
    return [
      line(header),
      '|${List.filled(header.length, ' --- ').join('|')}|',
      for (final row in rows) line(row),
      '',
    ].join('\n');
  }

  /// A cell must stay on one line and must not close the column early.
  static String _mdCell(String text) => text
      .replaceAll(r'\', r'\\')
      .replaceAll('|', r'\|')
      .replaceAll('\r\n', '<br>')
      .replaceAll(RegExp('[\r\n]'), '<br>');

  static String _csv(List<String> header, List<List<String>> rows) => [
    for (final row in [header, ...rows]) row.map(_csvField).join(','),
    '',
  ].join('\r\n');

  static String _csvField(String text) => text.contains(RegExp('[",\r\n]')) ? '"${text.replaceAll('"', '""')}"' : text;
}
