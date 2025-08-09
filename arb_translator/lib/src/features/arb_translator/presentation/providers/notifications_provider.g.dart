// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

/// Ephemeral notification provider.
@ProviderFor(NotificationMessage)
const notificationMessageProvider = NotificationMessageProvider._();

/// Ephemeral notification provider.
final class NotificationMessageProvider
    extends $NotifierProvider<NotificationMessage, String?> {
  /// Ephemeral notification provider.
  const NotificationMessageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationMessageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationMessageHash();

  @$internal
  @override
  NotificationMessage create() => NotificationMessage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$notificationMessageHash() =>
    r'8ed959a5b957f1cd92fcc15ca4cee5407efa025d';

abstract class _$NotificationMessage extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
