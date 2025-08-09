import 'dart:convert';
import 'package:arb_translator/src/features/arb_translator/data/datasources/openai_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('OpenAiRemoteDataSource.translate', () {
    test('returns content on 200', () async {
      final client = _MockClient();
      final ds = OpenAiRemoteDataSource(client);
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'Bonjour'},
              },
            ],
          }),
          200,
        ),
      );
      final res = await ds.translate(apiKey: 'k', prompt: 'prompt');
      expect(res, 'Bonjour');
    });

    test('retries on 429 then succeeds', () async {
      final client = _MockClient();
      final ds = OpenAiRemoteDataSource(client);
      int calls = 0;
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          return http.Response('too many', 429);
        }
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'Hola'},
              },
            ],
          }),
          200,
        );
      });
      final res = await ds.translate(apiKey: 'k', prompt: 'prompt');
      expect(res, 'Hola');
      expect(calls, 2);
    });

    test('throws after max retries', () async {
      final client = _MockClient();
      final ds = OpenAiRemoteDataSource(client);
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('err', 500));
      expect(() => ds.translate(apiKey: 'k', prompt: 'p'), throwsA(isA<Exception>()));
    });
  });
}
