import 'package:arb_translator/src/features/arb_translator/application/services/prompt_builder.dart';
import 'package:arb_translator/src/features/arb_translator/data/ai/openai_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/data/datasources/openai_remote_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final openAiDataSourceProvider = Provider<OpenAiRemoteDataSource>((ref) => OpenAiRemoteDataSource(http.Client()));

final promptBuilderProvider = Provider<PromptBuilder>((_) => const PromptBuilder());

final aiStrategyProvider = Provider<AiTranslationStrategy>((ref) {
  final ds = ref.watch(openAiDataSourceProvider);
  final pb = ref.watch(promptBuilderProvider);
  return OpenAiTranslationStrategy(ds, promptBuilder: pb);
});
