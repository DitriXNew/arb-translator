// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(ProjectController)
const projectControllerProvider = ProjectControllerProvider._();

final class ProjectControllerProvider extends $NotifierProvider<ProjectController, ProjectState> {
  const ProjectControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectControllerHash();

  @$internal
  @override
  ProjectController create() => ProjectController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ProjectState>(value));
  }
}

String _$projectControllerHash() => r'3aa1b2658f11fec5995592e055e5db6c78117f04';

abstract class _$ProjectController extends $Notifier<ProjectState> {
  ProjectState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProjectState, ProjectState>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<ProjectState, ProjectState>, ProjectState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
