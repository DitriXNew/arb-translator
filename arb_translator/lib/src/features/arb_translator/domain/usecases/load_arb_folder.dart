import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/repositories/translation_repository.dart';

class LoadArbFolder {
  LoadArbFolder(this.repo);
  final TranslationRepository repo;

  Future<(String baseLocale, List<String> locales, List<TranslationEntry> entries, String fileNamePrefix)> call(
    String path,
  ) async =>
      repo.loadFolder(path);
}
