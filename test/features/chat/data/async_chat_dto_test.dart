import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/chat/data/dto/async_chat_dto.dart';

void main() {
  group('AsyncChatResponseDto', () {
    test('parses all fields from JSON', () {
      final dto = AsyncChatResponseDto.fromJson({
        'task_id': 'task-abc123',
        'status': 'PENDING',
        'correlation_id': 'corr-42',
        'created_at': '2026-05-16T10:00:00Z',
        'estimated_wait_seconds': 45,
        'result_endpoint': '/chat/status/task-abc123',
      });

      expect(dto.taskId, 'task-abc123');
      expect(dto.status, 'PENDING');
      expect(dto.correlationId, 'corr-42');
      expect(dto.estimatedWaitSeconds, 45);
      expect(dto.resultEndpoint, '/chat/status/task-abc123');
    });

    test('uses defaults for optional fields', () {
      final dto = AsyncChatResponseDto.fromJson({
        'task_id': 't1',
        'correlation_id': 'c1',
        'created_at': '2026-05-16T10:00:00Z',
      });

      expect(dto.status, 'PENDING');
      expect(dto.estimatedWaitSeconds, 30);
      expect(dto.resultEndpoint, '');
    });
  });

  group('TaskStatusResponseDto', () {
    test('parses DONE status with result', () {
      final dto = TaskStatusResponseDto.fromJson({
        'task_id': 'task-abc123',
        'status': 'DONE',
        'created_at': '2026-05-16T10:00:00Z',
        'elapsed_seconds': 12.5,
        'completed_at': '2026-05-16T10:00:12Z',
        'result': {
          'response': 'Visa info here.',
          'language': 'ru',
          'pii_blocked': false,
          'correlation_id': 'corr-42',
        },
      });

      expect(dto.taskId, 'task-abc123');
      expect(dto.status, 'DONE');
      expect(dto.elapsedSeconds, closeTo(12.5, 0.01));
      expect(dto.completedAt, '2026-05-16T10:00:12Z');
      expect(dto.result, isNotNull);
      expect(dto.result!.response, 'Visa info here.');
    });

    test('parses FAILED status with error', () {
      final dto = TaskStatusResponseDto.fromJson({
        'task_id': 'task-xyz',
        'status': 'FAILED',
        'created_at': '2026-05-16T10:00:00Z',
        'elapsed_seconds': 5.0,
        'error': 'Timeout exceeded',
      });

      expect(dto.status, 'FAILED');
      expect(dto.error, 'Timeout exceeded');
      expect(dto.result, isNull);
    });

    test('parses PENDING status with null result', () {
      final dto = TaskStatusResponseDto.fromJson({
        'task_id': 'task-pending',
        'status': 'PENDING',
        'created_at': '2026-05-16T10:00:00Z',
        'elapsed_seconds': 2.0,
      });

      expect(dto.status, 'PENDING');
      expect(dto.result, isNull);
      expect(dto.error, isNull);
    });
  });
}
