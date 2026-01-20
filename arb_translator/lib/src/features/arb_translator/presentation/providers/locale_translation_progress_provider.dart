import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Translation progress state for a single locale
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

/// Translation progress state for all locales
class LocaleTranslationProgressState {
  const LocaleTranslationProgressState({this.localeProgress = const {}});

  /// Map: locale -> progress state
  final Map<String, LocaleTranslationProgress> localeProgress;

  /// Checks if translation is in progress for the given locale
  bool isTranslating(String locale) => localeProgress[locale]?.isTranslating ?? false;

  /// Checks if cancellation was requested for the given locale
  bool isCancelRequested(String locale) => localeProgress[locale]?.cancelRequested ?? false;

  /// Gets progress for a locale
  LocaleTranslationProgress? getProgress(String locale) => localeProgress[locale];

  /// Whether there are any active translations
  bool get hasActiveTranslations => localeProgress.values.any((p) => p.isTranslating);

  LocaleTranslationProgressState copyWith({Map<String, LocaleTranslationProgress>? localeProgress}) =>
      LocaleTranslationProgressState(localeProgress: localeProgress ?? this.localeProgress);
}

/// Notifier for managing translation progress by locale
class LocaleTranslationProgressNotifier extends Notifier<LocaleTranslationProgressState> {
  @override
  LocaleTranslationProgressState build() => const LocaleTranslationProgressState();

  /// Start translation for a locale
  void start(String locale, int total) {
    final newProgress = Map<String, LocaleTranslationProgress>.from(state.localeProgress);
    newProgress[locale] = LocaleTranslationProgress(isTranslating: true, total: total);
    state = state.copyWith(localeProgress: newProgress);
  }

  /// Update progress for a locale (add completed count)
  void updateProgress(String locale, int done) {
    final current = state.localeProgress[locale];
    if (current == null) return;

    final newProgress = Map<String, LocaleTranslationProgress>.from(state.localeProgress);
    newProgress[locale] = current.copyWith(done: done);
    state = state.copyWith(localeProgress: newProgress);
  }

  /// Increment progress counter by specified amount
  void incrementProgress(String locale, int count) {
    final current = state.localeProgress[locale];
    if (current == null) return;

    final newProgress = Map<String, LocaleTranslationProgress>.from(state.localeProgress);
    newProgress[locale] = current.copyWith(done: current.done + count);
    state = state.copyWith(localeProgress: newProgress);
  }

  /// Request cancellation of translation for a locale
  void requestCancel(String locale) {
    final current = state.localeProgress[locale];
    if (current == null || !current.isTranslating) return;

    final newProgress = Map<String, LocaleTranslationProgress>.from(state.localeProgress);
    newProgress[locale] = current.copyWith(cancelRequested: true);
    state = state.copyWith(localeProgress: newProgress);
  }

  /// Finish translation for a locale
  void finish(String locale) {
    final newProgress = Map<String, LocaleTranslationProgress>.from(state.localeProgress);
    newProgress.remove(locale);
    state = state.copyWith(localeProgress: newProgress);
  }

  /// Finish all translations
  void finishAll() {
    state = const LocaleTranslationProgressState();
  }
}

final localeTranslationProgressProvider =
    NotifierProvider<LocaleTranslationProgressNotifier, LocaleTranslationProgressState>(
      LocaleTranslationProgressNotifier.new,
    );
