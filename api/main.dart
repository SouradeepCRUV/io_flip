import 'dart:io';

import 'package:api/game_url.dart';
import 'package:cards_repository/cards_repository.dart';
import 'package:config_repository/config_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:db_client/db_client.dart';
import 'package:encryption_middleware/encryption_middleware.dart';
import 'package:firebase_cloud_storage/firebase_cloud_storage.dart';
import 'package:game_domain/game_domain.dart';
import 'package:game_script_machine/game_script_machine.dart';
import 'package:image_model_repository/image_model_repository.dart';
import 'package:jwt_middleware/jwt_middleware.dart';
import 'package:language_model_repository/language_model_repository.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:logging/logging.dart';
import 'package:match_repository/match_repository.dart';
import 'package:prompt_repository/prompt_repository.dart';
import 'package:scripts_repository/scripts_repository.dart';

import 'prompts.dart';

late CardsRepository cardsRepository;
late MatchRepository matchRepository;
late ScriptsRepository scriptsRepository;
late LeaderboardRepository leaderboardRepository;
late DbClient dbClient;
late GameScriptMachine gameScriptMachine;
late JwtMiddleware jwtMiddleware;
late EncryptionMiddleware encryptionMiddleware;
late GameUrl gameUrl;
late PromptRepository promptRepository;
late FirebaseCloudStorage firebaseCloudStorage;
late ScriptsState scriptsState;
late ConfigRepository configRepository;

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  final dbClient = DbClient.initialize(_appId, useEmulator: _useEmulator);

  configRepository = ConfigRepository(
    dbClient: dbClient,
  );

  promptRepository = PromptRepository(
    dbClient: dbClient,
  );
  final imageModelRepository = ImageModelRepository(
    imageHost:
        'https://firebasestorage.googleapis.com/v0/b/$_appId.appspot.com/o/public%2Fillustrations%2F',
    promptRepository: promptRepository,
    urlParams: '?alt=media',
  );

  final languageModelRepository = LanguageModelRepository(
    dbClient: dbClient,
    promptRepository: promptRepository,
  );
  jwtMiddleware = JwtMiddleware(
    projectId: _appId,
    isEmulator: _useEmulator,
  );
  encryptionMiddleware = const EncryptionMiddleware();

  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  scriptsRepository = ScriptsRepository(dbClient: dbClient);
  final initialScript = await scriptsRepository.getCurrentScript();

  gameScriptMachine = GameScriptMachine.initialize(initialScript);

  cardsRepository = CardsRepository(
    imageModelRepository: imageModelRepository,
    languageModelRepository: languageModelRepository,
    configRepository: configRepository,
    dbClient: dbClient,
    gameScriptMachine: gameScriptMachine,
  );

  matchRepository = MatchRepository(
    cardsRepository: cardsRepository,
    dbClient: dbClient,
    matchSolver: MatchSolver(gameScriptMachine: gameScriptMachine),
    trackPlayerPresence: Platform.environment['DISABLE_TAB_CHECK'] != 'true',
  );

  if (_useEmulator) {
    await dbClient.set(
      'initials_blacklist',
      DbEntityRecord(
        id: _initialsBlacklistId,
        data: const {
          'blacklist': ['TST'],
        },
      ),
    );

    const prompts = {
      PromptTermType.character: characters,
      PromptTermType.characterClass: classes,
      PromptTermType.power: powers,
      PromptTermType.location: locations,
    };

    var id = 0;
    for (final entry in prompts.entries) {
      for (final prompt in entry.value) {
        await dbClient.set(
          'prompt_terms',
          DbEntityRecord(
            id: 'id_${prompt}_${id++}',
            data: {
              'term': prompt,
              if (entry.key == PromptTermType.power)
                'shortenedTerm': prompt.replaceAll('ing', ''),
              'type': entry.key.name,
            },
          ),
        );
      }
    }
  }

  leaderboardRepository = LeaderboardRepository(
    dbClient: dbClient,
    blacklistDocumentId: _initialsBlacklistId,
  );

  firebaseCloudStorage = FirebaseCloudStorage(
    bucketName: _firebaseStorageBucket,
  );

  gameUrl = GameUrl(_gameUrl);

  scriptsState = _scriptsState;

  return serve(
    handler,
    ip,
    port,
  );
}

String get _appId {
  final value = "top-dash-dev-9e22b";
  // if (value == null) {
  //   throw ArgumentError('FB_APP_ID is required to run the API');
  // }
  return value;
}

String get projectId => _appId;

bool get _useEmulator => Platform.environment['USE_EMULATOR'] == 'true';

String get _gameUrl {
  final value = Platform.environment['GAME_URL'];
  if (value == null) {
    throw ArgumentError('GAME_URL is required to run the API');
  }
  return value;
}

String get _initialsBlacklistId {
  final value = Platform.environment['INITIALS_BLACKLIST_ID'];
  if (value == null) {
    throw ArgumentError('INITIALS_BLACKLIST_ID is required to run the API');
  }
  return value;
}

String get _firebaseStorageBucket {
  final value = Platform.environment['FB_STORAGE_BUCKET'];
  if (value == null) {
    throw ArgumentError('FB_STORAGE_BUCKET is required to run the API');
  }
  return value;
}

enum ScriptsState {
  enabled,
  disabled,
}

ScriptsState get _scriptsState {
  final value = Platform.environment['SCRIPTS_ENABLED'];
  if (value == null) {
    throw ArgumentError('SCRIPTS_ENABLED is required to run the API');
  }
  return value == 'true' ? ScriptsState.enabled : ScriptsState.disabled;
}
