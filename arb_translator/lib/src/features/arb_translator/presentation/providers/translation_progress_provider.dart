import 'package:flutter_riverpod/flutter_riverpod.dart';

class TranslationProgressState {
  const TranslationProgressState({
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
  TranslationProgressState copyWith({bool? isTranslating, int? done, int? total, bool? cancelRequested}) =>
      TranslationProgressState(
        isTranslating: isTranslating ?? this.isTranslating,
        done: done ?? this.done,
        total: total ?? this.total,
        cancelRequested: cancelRequested ?? this.cancelRequested,
      );
}

class TranslationProgress extends Notifier<TranslationProgressState> {
  @override
  TranslationProgressState build() => const TranslationProgressState();

  void start(int total) {
    state = TranslationProgressState(isTranslating: true, total: total);
  }

  void step() {
    if (state.done < state.total) {
      state = state.copyWith(done: state.done + 1);
    }
  }

  /// Update the completed count
  void updateDone(int done) {
    state = state.copyWith(done: done);
  }

  void finish() {
    state = state.copyWith(isTranslating: false);
  }

  void cancel() {
    if (!state.cancelRequested) {
      state = state.copyWith(cancelRequested: true);
    }
  }
}

final translationProgressProvider = NotifierProvider<TranslationProgress, TranslationProgressState>(
  TranslationProgress.new,
);
