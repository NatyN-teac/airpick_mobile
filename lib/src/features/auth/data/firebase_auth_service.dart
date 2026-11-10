import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/app_logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    appLogger.d("Starting signing with google");
    final googleSignIn = GoogleSignIn.instance;

    _googleInitFuture ??= googleSignIn.initialize(
      serverClientId: _androidServerClientId,
    );
    await _googleInitFuture;

    if (!googleSignIn.supportsAuthenticate()) {
      appLogger.w("NOT SUPPORTED: signing with google");
      throw const AuthConfigurationException(
        'Google sign-in is not supported on this platform.',
      );
    }

    try {
      appLogger.d("TRY: signing with google");
      final account = await googleSignIn.authenticate();
      final auth = account.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      appLogger.d("GET TOKEN: signing with google");
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

  // Sign in with Apple goes through FlutterFire's native flow
  // (ASAuthorizationController inside the firebase_auth plugin), which builds
  // the nonce and the credential with Firebase's own
  // `appleCredentialWithIDToken:rawNonce:fullName:`. The hand-built
  // `OAuthProvider('apple.com').credential(...)` path was rejected by Firebase
  // on TestFlight builds with "Invalid OAuth response from apple.com".
  // The Apple button is only shown on iOS / macOS.
  Future<String> signInWithApple() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    try {
      final userCredential = await _auth.signInWithProvider(provider);
      return await _getFirebaseToken(userCredential);
    } on FirebaseAuthException catch (e) {
      appLogger.w('[Auth] Apple sign-in failed: ${e.code} ${e.message}');
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        throw const AuthCancelledException('Apple');
      }
      throw AuthConfigurationException(
        'Apple sign-in failed: ${e.message ?? e.code}',
      );
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<String> _getFirebaseToken(UserCredential credential) async {
    // Force-refresh the ID token so registration uses the latest Firebase JWT.
    final token = await credential.user?.getIdToken(true);
    if (token == null) {
      throw const AuthConfigurationException(
        'Failed to retrieve Firebase ID token.',
      );
    }
    return token;
  }
}
