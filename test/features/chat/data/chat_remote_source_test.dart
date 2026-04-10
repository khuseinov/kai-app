import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/api/api_client.dart';
import 'package:kai_app/features/chat/data/chat_remote_source.dart';
import 'package:kai_app/features/chat/data/dto/chat_request_dto.dart';

class FakeApiClient extends ApiClient {
  Map<String, dynamic>? _sendMessageResponse;
  Object? _sendMessageError;

  FakeApiClient() : super(Dio());

  void setSendMessageResponse(Map<String, dynamic> data) {
    _sendMessageResponse = data;
  }

  void setSendMessageError(Object error) {
    _sendMessageError = error;
  }

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String userId,
    required String sessionId,
  }) async {
    if (_sendMessageError != null) throw _sendMessageError!;
    return _sendMessageResponse!;
  }
}

void main() {
  late FakeApiClient apiClient;
  late ChatRemoteSource remoteSource;

  setUp(() {
    apiClient = FakeApiClient();
    remoteSource = ChatRemoteSource(apiClient);
  });

  test('sendMessage returns parsed ChatResponseDto', () async {
    apiClient.setSendMessageResponse({
      'response': 'Paris is lovely in autumn!',
      'language': 'en',
      'model': 'gpt-4',
      'provider': 'openai',
    });

    final request = ChatRequestDto(
      message: 'Tell me about Paris',
      userId: 'user-1',
      sessionId: 'sess-1',
    );

    final result = await remoteSource.sendMessage(request);

    expect(result.response, 'Paris is lovely in autumn!');
    expect(result.language, 'en');
    expect(result.model, 'gpt-4');
    expect(result.provider, 'openai');
  });

  test('sendMessage returns dto with optional fields null', () async {
    apiClient.setSendMessageResponse({
      'response': 'Simple answer',
    });

    final request = ChatRequestDto(
      message: 'Hi',
      userId: 'user-1',
      sessionId: 'sess-1',
    );

    final result = await remoteSource.sendMessage(request);

    expect(result.response, 'Simple answer');
    expect(result.language, isNull);
    expect(result.model, isNull);
    expect(result.provider, isNull);
  });

  test('sendMessage throws when apiClient throws', () async {
    apiClient.setSendMessageError(Exception('Connection refused'));

    final request = ChatRequestDto(
      message: 'Hi',
      userId: 'user-1',
      sessionId: 'sess-1',
    );

    expect(
      () => remoteSource.sendMessage(request),
      throwsA(isA<Exception>()),
    );
  });
}
