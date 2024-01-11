// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:js' as js;

import 'package:api_client/api_client.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:config_repository/config_repository.dart';
import 'package:connection_repository/connection_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:game_domain/game_domain.dart';
import 'package:game_script_machine/game_script_machine.dart';
import 'package:io_flip/app/app.dart';
import 'package:io_flip/bootstrap.dart';
import 'package:io_flip/firebase_options_development.dart';
import 'package:io_flip/settings/persistence/persistence.dart';
import 'package:match_maker_repository/match_maker_repository.dart';

void main() async {
  if (kDebugMode) {
    js.context['FIREBASE_APPCHECK_DEBUG_TOKEN'] =
        const String.fromEnvironment('APPCHECK_DEBUG_TOKEN');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
if (kDebugMode) {
  print('0');
}
  unawaited(
    bootstrap(
      (firestore, firebaseAuth, appCheck) async {
        await appCheck.activate(
          webRecaptchaSiteKey: const String.fromEnvironment('RECAPTCHA_KEY'),
        );
        if (kDebugMode) {
          print('RECAPTCHA');
        }
        await appCheck.setTokenAutoRefreshEnabled(true);

        final authenticationRepository = AuthenticationRepository(
          firebaseAuth: firebaseAuth,
        );

        if (kDebugMode) {
          print('1');
        }
        final apiClient = ApiClient(
          baseUrl: 'https://top-dash-dev-api-synvj3dcmq-uc.a.run.app',
          idTokenStream: authenticationRepository.idToken,
          refreshIdToken: authenticationRepository.refreshIdToken,
          appCheckTokenStream: appCheck.onTokenChange,
          appCheckToken: await appCheck.getToken(),
        );

        if (kDebugMode) {
          print('Api');
        }
        await authenticationRepository.signInAnonymously();
        if (kDebugMode) {
          print('Sign in');
        }
        await authenticationRepository.idToken.first;
        if (kDebugMode) {
          print('Token');
        }
        final currentScript =
            await apiClient.scriptsResource.getCurrentScript(); //problem: XMLHttpRequest error.
        if (kDebugMode) {
          print('Script');
        }
        final gameScriptMachine = GameScriptMachine.initialize(currentScript);

        if (kDebugMode) {
          print('Initialize');
        }
        if (kDebugMode) {
          print('0');
        }
        return App(
          settingsPersistence: LocalStorageSettingsPersistence(),
          apiClient: apiClient,
          matchMakerRepository: MatchMakerRepository(db: firestore),
          configRepository: ConfigRepository(db: firestore),
          connectionRepository: ConnectionRepository(apiClient: apiClient),
          matchSolver: MatchSolver(gameScriptMachine: gameScriptMachine),
          gameScriptMachine: gameScriptMachine,
          user: await authenticationRepository.user.first,
          isScriptsEnabled: true,
        );
      },
    ),
  );
}
