import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connection_repository/connection_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:game_domain/game_domain.dart';
import 'package:visibility_repository/visibility_repository.dart';

part 'connection_event.dart';
part 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  ConnectionBloc({
    required ConnectionRepository connectionRepository,
    required VisibilityRepository visibilityRepository,
  })  : _connectionRepository = connectionRepository,
        _visibilityRepository = visibilityRepository,
        super(const ConnectionInitial()) {
    on<ConnectionRequested>(_onConnectionRequested);
    on<ConnectionClosed>(_onConnectionClosed);
    on<WebSocketMessageReceived>(_onWebSocketMessageReceived);

    _visibilitySubscription =
        _visibilityRepository.visibility.listen(_visibilityChange);
  }

  final ConnectionRepository _connectionRepository;
  final VisibilityRepository _visibilityRepository;
  StreamSubscription<bool>? _visibilitySubscription;
  StreamSubscription<WebSocketMessage>? _messageSubscription;
  Timer? _backgroundedTimer;

  void _visibilityChange(bool visible) {
    _backgroundedTimer?.cancel();

    if (visible) {
      if (state is ConnectionInitial || state is ConnectionFailure) {
        add(const ConnectionRequested());
      }
    } else {
      _backgroundedTimer = Timer(
        const Duration(seconds: 3),
        _connectionRepository.close,
      );
    }
  }

  @override
  Future<void> close() async {
    await _messageSubscription?.cancel();
    await _visibilitySubscription?.cancel();
    _backgroundedTimer?.cancel();
    _connectionRepository.close();
    return super.close();
  }

  Future<void> _onConnectionRequested(
    ConnectionRequested event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(const ConnectionInProgress());
    try {
      await _messageSubscription?.cancel();
      _connectionRepository.close();
      await _connectionRepository.connect();
      _messageSubscription = _connectionRepository.messages.listen(
        (message) => add(WebSocketMessageReceived(message)),
        onDone: () => add(const ConnectionClosed()),
      );
    } catch (e, s) {
      emit(const ConnectionFailure(WebSocketErrorCode.unknown));
      addError(e, s);
    }
  }

  Future<void> _onConnectionClosed(
    ConnectionClosed event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(const ConnectionInitial());
    await _messageSubscription?.cancel();
  }

  Future<void> _onWebSocketMessageReceived(
    WebSocketMessageReceived event,
    Emitter<ConnectionState> emit,
  ) async {
    final message = event.message;
    if (message.messageType == MessageType.connected) {
      emit(const ConnectionSuccess());
    } else if (message.messageType == MessageType.error) {
      final payload = message.payload! as WebSocketErrorPayload;
      emit(ConnectionFailure(payload.errorCode));
    }
  }
}
