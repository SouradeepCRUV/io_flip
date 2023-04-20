import 'dart:convert' show base64Url, json, utf8;
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:x509/x509.dart';

Uint8List _base64Decode(String encoded) {
  final padding = '=' * (4 - encoded.length % 4);
  return base64Url.decode(encoded + padding);
}

Map<String, dynamic> _jsonBase64Decode(String encoded) {
  return Map<String, dynamic>.from(
    json.decode(utf8.decode(_base64Decode(encoded))) as Map,
  );
}

/// {@template jwt}
/// Represents a JSON Web Token.
/// {@endtemplate}
class JWT {
  /// {@macro jwt}
  JWT({
    required Uint8List body,
    required Signature? signature,
    required Map<String, dynamic> payload,
    required Map<String, dynamic> header,
  })  : _body = body,
        _signature = signature,
        _payload = payload,
        _header = header;

  /// Parses a [JWT] from an encoded token string.
  factory JWT.from(String token) {
    final segments = token.split('.');
    final header = _jsonBase64Decode(segments[0]);

    final body = utf8.encode('${segments[0]}.${segments[1]}');
    final signature =
        segments[2].isNotEmpty ? Signature(_base64Decode(segments[2])) : null;

    return JWT(
      body: Uint8List.fromList(body),
      signature: signature,
      payload: _jsonBase64Decode(segments[1]),
      header: header,
    );
  }

  final Uint8List _body;
  final Signature? _signature;
  final Map<String, dynamic> _payload;
  final Map<String, dynamic> _header;

  /// The user id stored in this token.
  String? get userId => _payload['user_id'] as String?;

  /// The key id of the key used to sign this token.
  String? get keyId => _header['kid'] as String?;

  /// The aud of this token
  String? get aud => _payload['aud'] as String?;

  /// The iss of this token
  String? get iss => _payload['iss'] as String?;

  /// Verifies the signature of this token with the given [verifier].
  bool verifyWith(Verifier<PublicKey> verifier) {
    if (_signature == null) return false;

    return verifier.verify(_body, _signature!);
  }

  /// Validates the common fields of this token.
  bool validateCommonFields(int nowSeconds) {
    if (_header['alg'] != 'RS256') {
      return false;
    }
    final exp = _payload['exp'] as int?;
    final iat = _payload['iat'] as int?;
    final sub = _payload['sub'] as String?;

    if (exp == null ||
        iat == null ||
        aud == null ||
        iss == null ||
        sub == null) {
      return false;
    }

    if (exp <= nowSeconds) {
      return false;
    }
    if (iat > nowSeconds) {
      return false;
    }
    return true;
  }

  /// Validates the fields of this token.
  bool validate(String projectId) {
    final nowSeconds = clock.now().millisecondsSinceEpoch ~/ 1000;
    final sub = _payload['sub'] as String?;
    final authTime = _payload['auth_time'] as int?;
    final userId = _payload['user_id'] as String?;

    if (authTime == null ||
        userId == null ||
        !validateCommonFields(nowSeconds)) {
      return false;
    }

    if (aud != projectId) {
      return false;
    }
    if (iss != 'https://securetoken.google.com/$projectId') {
      return false;
    }

    if (authTime > nowSeconds) {
      return false;
    }
    if (sub != userId) {
      return false;
    }

    return true;
  }

  /// Validates the fields of this token for gcloud user.
  bool validateGcloudUser(String projectId) {
    final nowSeconds = clock.now().millisecondsSinceEpoch ~/ 1000;
    final email = _payload['email'] as String?;

    if (email == null || !validateCommonFields(nowSeconds)) return false;

    if (iss != 'https://accounts.google.com') {
      return false;
    }
    if (email != 'api-service-account@$projectId.iam.gserviceaccount.com') {
      return false;
    }

    return true;
  }
}
