// ignore_for_file: prefer_const_constructors

import 'package:cards_repository/cards_repository.dart';
import 'package:test/test.dart';

void main() {
  group('Card', () {
    test('can be instantiated', () {
      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        isNotNull,
      );
    });

    test('toJson returns the instance as json', () {
      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ).toJson(),
        equals({
          'id': '',
          'name': '',
          'description': '',
          'image': '',
          'rarity': false,
          'design': 1,
          'frontend': 1,
          'backend': 1,
          'product': 1,
        }),
      );
    });

    test('supports equality', () {
      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        equals(
          Card(
            id: '',
            name: '',
            description: '',
            image: '',
            rarity: false,
            design: 1,
            frontend: 1,
            backend: 1,
            product: 1,
          ),
        ),
      );

      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        isNot(
          equals(
            Card(
              id: '1',
              name: '',
              description: '',
              image: '',
              rarity: false,
              design: 1,
              frontend: 1,
              backend: 1,
              product: 1,
            ),
          ),
        ),
      );

      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        isNot(
          equals(
            Card(
              id: '',
              name: 'a',
              description: '',
              image: '',
              rarity: false,
              design: 1,
              frontend: 1,
              backend: 1,
              product: 1,
            ),
          ),
        ),
      );

      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        isNot(
          equals(
            Card(
              id: '',
              name: '',
              description: 'a',
              image: '',
              rarity: false,
              design: 1,
              frontend: 1,
              backend: 1,
              product: 1,
            ),
          ),
        ),
      );

      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        isNot(
          equals(
            Card(
              id: '',
              name: '',
              description: '',
              image: 'a',
              rarity: false,
              design: 1,
              frontend: 1,
              backend: 1,
              product: 1,
            ),
          ),
        ),
      );

      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        isNot(
          equals(
            Card(
              id: '',
              name: '',
              description: '',
              image: '',
              rarity: true,
              design: 1,
              frontend: 1,
              backend: 1,
              product: 1,
            ),
          ),
        ),
      );

      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        isNot(
          equals(
            Card(
              id: '',
              name: '',
              description: '',
              image: '',
              rarity: false,
              design: 2,
              frontend: 1,
              backend: 1,
              product: 1,
            ),
          ),
        ),
      );

      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        isNot(
          equals(
            Card(
              id: '',
              name: '',
              description: '',
              image: '',
              rarity: false,
              design: 1,
              frontend: 2,
              backend: 1,
              product: 1,
            ),
          ),
        ),
      );

      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        isNot(
          equals(
            Card(
              id: '',
              name: '',
              description: '',
              image: '',
              rarity: false,
              design: 1,
              frontend: 1,
              backend: 2,
              product: 1,
            ),
          ),
        ),
      );

      expect(
        Card(
          id: '',
          name: '',
          description: '',
          image: '',
          rarity: false,
          design: 1,
          frontend: 1,
          backend: 1,
          product: 1,
        ),
        isNot(
          equals(
            Card(
              id: '',
              name: '',
              description: '',
              image: '',
              rarity: false,
              design: 1,
              frontend: 1,
              backend: 1,
              product: 2,
            ),
          ),
        ),
      );
    });
  });
}
