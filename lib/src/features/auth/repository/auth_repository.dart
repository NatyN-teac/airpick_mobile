import '../data/firebase_auth_service.dart';
import '../models/user_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../home/cubit/user_mode_cubit.dart';
import '../../settings/repository/settings_repository.dart';

abstract class IAuthRepository {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
}

class AuthRepository implements IAuthRepository {
  final FirebaseAuthService _firebaseService;
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  final SettingsRepository _settings;

  const AuthRepository({
    required FirebaseAuthService firebaseService,
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
    required SettingsRepository settings,
  })  : _firebaseService = firebaseService,
        _apiClient = apiClient,
        _tokenStorage = tokenStorage,
        _settings = settings;

  @override
  Future<UserModel> signInWithGoogle() => _register(
        () => _firebaseService.signInWithGoogle(),
      );

  @override
  Future<UserModel> signInWithApple() => _register(
        () => _firebaseService.signInWithApple(),
      );

  Future<UserModel> _register(
    Future<String> Function() getFirebaseToken,
  ) async {
    final firebaseToken = await getFirebaseToken();

    final response = await _apiClient.post(
      '/users/register',
      {
        'firebaseToken': firebaseToken,
        'mode': _settings.getMode().apiValue,
      },
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Registration failed.');
    }
    final rawData = response['content'];

    if (rawData == null) {
      throw Exception(
        'Server returned success but no content.\nFull response: $response',
      );
    }

    if (rawData is! Map<String, dynamic>) {
      throw Exception(
        'Unexpected content format: ${rawData.runtimeType}\nFull response: $response',
      );
    }

    final user = UserModel.fromJson(rawData);

    await _tokenStorage.saveToken(user.token);
    await _tokenStorage.saveUserId(user.id);

    return user;
  }
}
