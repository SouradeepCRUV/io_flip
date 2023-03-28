// ignore_for_file: avoid_print, unused_local_variable

import 'package:api_client/api_client.dart';

void main() async {
  const url = 'ws://top-dash-dev-api-synvj3dcmq-uc.a.run.app';
  const localUrl = 'ws://localhost:8080';

  final client = ApiClient(
    baseUrl: localUrl,
    idTokenStream: const Stream.empty(),
    refreshIdToken: () async => null,
  );

  final channel = await client.gameResource.connectToMatch(
    matchId: '1ldDtz5qg33hKt95Y4l2',
    isHost: true,
  );
  channel.messages.listen(print);
}