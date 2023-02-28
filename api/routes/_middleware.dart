import 'dart:io';

import 'package:cards_repository/cards_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import '../main.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<CardsRepository>((_) => cardsRepository))
      .use(
        fromShelfMiddleware(
          corsHeaders(
            headers: {
              ACCESS_CONTROL_ALLOW_ORIGIN: _corsDomain,
            },
          ),
        ),
      );
}

String get _corsDomain {
  final value = Platform.environment['CORS_DOMAIN'];
  if (value == null) {
    throw ArgumentError('CORS_DOMAIN is required to run the API');
  }
  return value;
}
