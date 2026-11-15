// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProjectController)
final projectControllerProvider = ProjectControllerProvider._();

final class ProjectControllerProvider extends $NotifierProvider<ProjectController, ProjectState> {
  ProjectControllerProvider._()
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

String _$projectControllerHash() => r'2aa76dab90f05c1aaabc33342c7f5610863e4ec4';

abstract class _$ProjectController extends $Notifier<ProjectState> {
  ProjectState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProjectState, ProjectState>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<ProjectState, ProjectState>, ProjectState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
