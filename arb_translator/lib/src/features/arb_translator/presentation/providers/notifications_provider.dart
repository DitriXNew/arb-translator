import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_provider.g.dart';

/// Ephemeral notification provider.
@riverpod
class NotificationMessage extends _$NotificationMessage {
  @override
  String? build() => null;

  String? get message => state;

  set message(String? value) => state = value;

  void clearMessage() => state = null;
}
