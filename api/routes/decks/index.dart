import 'dart:async';
import 'dart:io';

import 'package:cards_repository/cards_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:logging/logging.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    final json = await context.request.json() as Map<String, dynamic>;
    final cards = json['cards'];

    if (!_isListOfString(cards)) {
      context.read<Logger>().warning(
            'Received invalid payload: $json',
          );
      return Response(statusCode: HttpStatus.badRequest);
    }

    final ids = (cards as List).cast<String>();

    final cardsRepository = context.read<CardsRepository>();
    final deckId = await cardsRepository.createDeck(ids);
    return Response.json(body: {'id': deckId});
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

bool _isListOfString(dynamic value) {
  if (value is! List) {
    return false;
  }

  return value.whereType<String>().length == value.length;
}