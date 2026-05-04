import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/settings/data/user_remote_source.dart';
import 'package:kai_app/features/settings/logic/delete_data_notifier.dart';

class _FakeRemote implements UserRemoteSource {
  bool wasCalled = false;
  bool shouldFail = false;
  String? receivedUserId;

  @override
  Future<void> deleteTrajectory(String userId) async {
    receivedUserId = userId;
    wasCalled = true;
    if (shouldFail) throw Exception('boom');
  }
}

void main() {
  test('initial state is idle', () {
    final notifier = DeleteDataNotifier(_FakeRemote(), 'user-1');
    expect(notifier.state, DeleteDataState.idle);
  });

  test('successful delete transitions idle -> deleting -> success', () async {
    final remote = _FakeRemote();
    final notifier = DeleteDataNotifier(remote, 'user-1');

    final future = notifier.deleteAll();
    expect(notifier.state, DeleteDataState.deleting);
    await future;
    expect(notifier.state, DeleteDataState.success);
    expect(remote.receivedUserId, 'user-1');
    expect(remote.wasCalled, true);
  });

  test('failure transitions to error', () async {
    final remote = _FakeRemote()..shouldFail = true;
    final notifier = DeleteDataNotifier(remote, 'user-1');

    await notifier.deleteAll();
    expect(notifier.state, DeleteDataState.error);
  });

  test('reset returns to idle from any state', () async {
    final notifier = DeleteDataNotifier(_FakeRemote(), 'user-1');
    await notifier.deleteAll();
    expect(notifier.state, DeleteDataState.success);

    notifier.reset();
    expect(notifier.state, DeleteDataState.idle);
  });
}
