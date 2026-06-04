import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

abstract class IOnboardingRepository {
  Future<bool> isOnboardingCompleted();
  Future<void> completeOnboarding();
}

class OnboardingRepository implements IOnboardingRepository {
  const OnboardingRepository();

  @override
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
  }

  @override
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompletedKey, true);
  }
}
