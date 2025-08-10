// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_cell_translation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

/// Active per-cell translation indicator using a generated Notifier provider.
/// Stores (key, locale) of the cell currently being translated.
@ProviderFor(ActiveCellTranslation)
const activeCellTranslationProvider = ActiveCellTranslationProvider._();

/// Active per-cell translation indicator using a generated Notifier provider.
/// Stores (key, locale) of the cell currently being translated.
final class ActiveCellTranslationProvider extends $NotifierProvider<ActiveCellTranslation, (String, String)?> {
  /// Active per-cell translation indicator using a generated Notifier provider.
  /// Stores (key, locale) of the cell currently being translated.
  const ActiveCellTranslationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCellTranslationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCellTranslationHash();

  @$internal
  @override
  ActiveCellTranslation create() => ActiveCellTranslation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue((String, String)? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<(String, String)?>(value));
  }
}

String _$activeCellTranslationHash() => r'908ae727af2f8798fae446932e0d3417b10e8569';

abstract class _$ActiveCellTranslation extends $Notifier<(String, String)?> {
  (String, String)? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<(String, String)?, (String, String)?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<(String, String)?, (String, String)?>,
              (String, String)?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
