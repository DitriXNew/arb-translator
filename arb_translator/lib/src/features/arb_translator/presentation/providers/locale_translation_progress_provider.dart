import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Состояние прогресса перевода для одного языка
class LocaleTranslationProgress {
  const LocaleTranslationProgress({
    this.isTranslating = false,
    this.done = 0,
    this.total = 0,
    this.cancelRequested = false,
  });

  final bool isTranslating;
  final int done;
  final int total;
  final bool cancelRequested;

  double get progress => total == 0 ? 0 : done / total;

  LocaleTranslationProgress copyWith({bool? isTranslating, int? done, int? total, bool? cancelRequested}) =>
      LocaleTranslationProgress(
        isTranslating: isTranslating ?? this.isTranslating,
        done: done ?? this.done,
        total: total ?? this.total,
        cancelRequested: cancelRequested ?? this.cancelRequested,
      );
}

/// Состояние прогресса перевода для всех языков
class LocaleTranslationProgressState {
  const LocaleTranslationProgressState({this.localeProgress = const {}});

  /// Map: locale -> progress state
  final Map<String, LocaleTranslationProgress> localeProgress;

  /// Проверяет, идёт ли перевод для данного языка
  bool isTranslating(String locale) => localeProgress[locale]?.isTranslating ?? false;

  /// Проверяет, запрошена ли отмена для данного языка
  bool isCancelRequested(String locale) => localeProgress[locale]?.cancelRequested ?? false;

  /// Получает прогресс для языка
  LocaleTranslationProgress? getProgress(String locale) => localeProgress[locale];

  /// Есть ли активные переводы
  bool get hasActiveTranslations => localeProgress.values.any((p) => p.isTranslating);

  LocaleTranslationProgressState copyWith({Map<String, LocaleTranslationProgress>? localeProgress}) =>
      LocaleTranslationProgressState(localeProgress: localeProgress ?? this.localeProgress);
}

/// Notifier для управления прогрессом перевода по языкам
class LocaleTranslationProgressNotifier extends Notifier<LocaleTranslationProgressState> {
  @override
  LocaleTranslationProgressState build() => const LocaleTranslationProgressState();

  /// Начать перевод для языка
  void start(String locale, int total) {
    final newProgress = Map<String, LocaleTranslationProgress>.from(state.localeProgress);
    newProgress[locale] = LocaleTranslationProgress(isTranslating: true, total: total);
    state = state.copyWith(localeProgress: newProgress);
  }

  /// Обновить прогресс для языка (добавить завершённые)
  void updateProgress(String locale, int done) {
    final current = state.localeProgress[locale];
    if (current == null) return;

    final newProgress = Map<String, LocaleTranslationProgress>.from(state.localeProgress);
    newProgress[locale] = current.copyWith(done: done);
    state = state.copyWith(localeProgress: newProgress);
  }

  /// Увеличить счётчик на указанное количество
  void incrementProgress(String locale, int count) {
    final current = state.localeProgress[locale];
    if (current == null) return;

    final newProgress = Map<String, LocaleTranslationProgress>.from(state.localeProgress);
    newProgress[locale] = current.copyWith(done: current.done + count);
    state = state.copyWith(localeProgress: newProgress);
  }

  /// Запросить отмену перевода для языка
  void requestCancel(String locale) {
    final current = state.localeProgress[locale];
    if (current == null || !current.isTranslating) return;

    final newProgress = Map<String, LocaleTranslationProgress>.from(state.localeProgress);
    newProgress[locale] = current.copyWith(cancelRequested: true);
    state = state.copyWith(localeProgress: newProgress);
  }

  /// Завершить перевод для языка
  void finish(String locale) {
    final newProgress = Map<String, LocaleTranslationProgress>.from(state.localeProgress);
    newProgress.remove(locale);
    state = state.copyWith(localeProgress: newProgress);
  }

  /// Завершить все переводы
  void finishAll() {
    state = const LocaleTranslationProgressState();
  }
}

final localeTranslationProgressProvider =
    NotifierProvider<LocaleTranslationProgressNotifier, LocaleTranslationProgressState>(
      LocaleTranslationProgressNotifier.new,
    );
