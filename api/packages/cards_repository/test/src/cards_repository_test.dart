// ignore_for_file: prefer_const_constructors
import 'dart:math';

import 'package:cards_repository/cards_repository.dart';
import 'package:db_client/db_client.dart';
import 'package:game_domain/game_domain.dart';
import 'package:image_model_repository/image_model_repository.dart';
import 'package:language_model_repository/language_model_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockCardRng extends Mock implements CardRng {}

class _MockImageModelRepository extends Mock implements ImageModelRepository {}

class _MockLanguageModelRepository extends Mock
    implements LanguageModelRepository {}

class _MockRandom extends Mock implements Random {}

class _MockDbClient extends Mock implements DbClient {}

void main() {
  group('CardsRepository', () {
    late CardRng cardRng;
    late ImageModelRepository imageModelRepository;
    late LanguageModelRepository languageModelRepository;
    late CardsRepository cardsRepository;
    late DbClient dbClient;

    setUp(() {
      cardRng = _MockCardRng();
      when(cardRng.rollRarity).thenReturn(false);
      when(
        () => cardRng.rollAttribute(
          base: any(named: 'base'),
          modifier: any(named: 'modifier'),
        ),
      ).thenReturn(10);
      imageModelRepository = _MockImageModelRepository();
      when(imageModelRepository.generateImage)
          .thenAnswer((_) async => 'https://image.png');

      languageModelRepository = _MockLanguageModelRepository();
      when(languageModelRepository.generateCardName)
          .thenAnswer((_) async => 'Super Bird');
      when(languageModelRepository.generateFlavorText)
          .thenAnswer((_) async => 'Super Bird Is Ready!');

      dbClient = _MockDbClient();
      when(() => dbClient.add('cards', any())).thenAnswer((_) async => 'abc');

      cardsRepository = CardsRepository(
        imageModelRepository: imageModelRepository,
        languageModelRepository: languageModelRepository,
        dbClient: dbClient,
        rng: cardRng,
      );
    });

    test('can be instantiated', () {
      expect(
        CardsRepository(
          imageModelRepository: const ImageModelRepository(),
          languageModelRepository: const LanguageModelRepository(),
          dbClient: dbClient,
        ),
        isNotNull,
      );
    });

    test('generates a common card', () async {
      final card = await cardsRepository.generateCard();

      expect(
        card,
        Card(
          id: 'abc',
          name: 'Super Bird',
          description: 'Super Bird Is Ready!',
          image: 'https://image.png',
          rarity: false,
          power: 10,
        ),
      );
    });

    test('saves the card in the db', () async {
      await cardsRepository.generateCard();

      verify(
        () => dbClient.add('cards', {
          'name': 'Super Bird',
          'description': 'Super Bird Is Ready!',
          'image': 'https://image.png',
          'rarity': false,
          'power': 10,
        }),
      ).called(1);
    });

    test('generates a rare card', () async {
      when(cardRng.rollRarity).thenReturn(true);
      final card = await cardsRepository.generateCard();

      expect(
        card,
        Card(
          id: 'abc',
          name: 'Super Bird',
          description: 'Super Bird Is Ready!',
          image: 'https://image.png',
          rarity: true,
          power: 10,
        ),
      );

      verify(() => cardRng.rollAttribute(base: 10, modifier: 10)).called(1);
    });
  });

  group('CardRng', () {
    late Random rng;
    late CardRng cardRng;

    setUp(() {
      rng = _MockRandom();
      cardRng = CardRng(rng: rng);
    });

    test('can be instantiated', () {
      expect(CardRng(), isNotNull);
    });

    test('rollRarity returns true when less than the chance threshold', () {
      when(rng.nextDouble).thenReturn(CardRng.rareChance - .1);
      expect(cardRng.rollRarity(), isTrue);
    });

    test('rollRarity returns false when greater than the chance threshold', () {
      when(rng.nextDouble).thenReturn(CardRng.rareChance + .1);
      expect(cardRng.rollRarity(), isFalse);
    });

    test('rollAttribute returns a value between the base value', () {
      when(rng.nextDouble).thenReturn(.3);
      expect(cardRng.rollAttribute(base: 10), equals(3));
    });

    test('rollAttribute adds the given modifier', () {
      when(rng.nextDouble).thenReturn(.3);
      expect(
        cardRng.rollAttribute(base: 10, modifier: 3),
        equals(6),
      );
    });
  });
}
