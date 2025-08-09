import 'package:arb_translator/src/core/constants/k_regex.dart';

Set<String> extractPlaceholdersFromText(String s) =>
    placeholderPattern.allMatches(s).map((m) => m.group(1)!).toSet();

bool placeholdersMatch({
  required Set<String> english,
  required Set<String> target,
}) => english.length == target.length && english.containsAll(target);
