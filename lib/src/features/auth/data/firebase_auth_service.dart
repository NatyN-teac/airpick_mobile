import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../exceptions/auth_exceptions.dart';

class FirebaseAuthService {
  // Web client ID (OAuth client type 3) from google-services.json.
  // Required by the Android Credential Manager API (google_sign_in v7+)
  // to request a Google ID token. Replace with your own value.
  static const _androidServerClientId =
      '960865698662-3ev26ktp2gmkdnlqi7ivcko26pmuufn8.apps.googleusercontent.com';

  static Future<void>? _googleInitFuture;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<String> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    _googleInitFuture ??= googleSignIn.initialize(
      serverClientId: _androidServerClientId,
    );
    await _googleInitFuture;

    if (!googleSignIn.supportsAuthenticate()) {
      throw const AuthConfigurationException(
        'Google sign-in is not supported on this platform.',
      );
    }

    try {
      final account = await googleSignIn.authenticate();
      final auth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return await _getFirebaseToken(userCredential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException('Google');
      }
      if (e.code == GoogleSignInExceptionCode.providerConfigurationError ||
          (e.description?.contains('reauth') ?? false)) {
        throw AuthConfigurationException(
          'Google sign-in configuration error: ${e.description}',
        );
      }
      rethrow;
    }
  }

  Future<String> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final identityToken = appleCredential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw const AuthConfigurationException(
          'Apple did not return an identity token.',
        );
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      return await _getFirebaseToken(userCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthCancelledException('Apple');
      }
      rethrow;
    }
  }

  Future<String> _getFirebaseToken(UserCredential credential) async {
    final token = await credential.user?.getIdToken();
    if (token == null) {
      throw const AuthConfigurationException(
        'Failed to retrieve Firebase ID token.',
      );
    }
    return token;
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
