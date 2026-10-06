import 'package:arb_translator/src/core/utils/arb_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('extractPlaceholdersFromText', () {
    test('plain placeholders', () {
      expect(extractPlaceholdersFromText('Hello {name}, you have {count} files'), {'name', 'count'});
    });

    test('the argument of a plural is a placeholder, a one-word case body is not', () {
      expect(extractPlaceholdersFromText('{count, plural, =1{segment} other{{count} segments}}'), {'count'});
    });

    test('placeholders nested inside select cases are found', () {
      expect(extractPlaceholdersFromText('{rule, select, nonEmpty{at least {limit} item} other{check it}}'), {
        'rule',
        'limit',
      });
    });

    test('a renamed plural argument is visible', () {
      final english = extractPlaceholdersFromText('{count, plural, =1{One file} other{{count} files}}');
      final german = extractPlaceholdersFromText('{anzahl, plural, =1{Eine Datei} other{{count} Dateien}}');
      expect(placeholdersMatch(english: english, target: german), isFalse);
    });

    test('a translated one-word case body still matches', () {
      final english = extractPlaceholdersFromText('{count, plural, =1{segment} other{{count} segments}}');
      final german = extractPlaceholdersFromText('{count, plural, =1{Segment} other{{count} Segmente}}');
      expect(placeholdersMatch(english: english, target: german), isTrue);
    });

    test('the argument of a date or time format is a placeholder', () {
      expect(extractPlaceholdersFromText('Saved {when, date, ::yMMMd} at {when, time, ::Hm}'), {'when'});
    });

    test('a renamed typed argument is visible', () {
      final english = extractPlaceholdersFromText('Total: {amount, number}');
      final german = extractPlaceholdersFromText('Summe: {summe, number}');
      expect(placeholdersMatch(english: english, target: german), isFalse);
    });

    test("quotes are text: gen-l10n's default syntax (use-escaping: false) is the one checked", () {
      expect(extractPlaceholdersFromText("Tap '{name}' to continue"), {'name'});
      expect(hasBalancedBraces("Tap '{' to continue"), isFalse);
    });

    test('unbalanced braces do not throw', () {
      expect(extractPlaceholdersFromText('{count, plural, other{{count} files'), {'count'});
      expect(extractPlaceholdersFromText('broken } text {'), isEmpty);
    });
  });
}
