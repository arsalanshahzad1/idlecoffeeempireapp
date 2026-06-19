import '../../models/player_profile.dart';

abstract class UserProfileService {
  Future<PlayerProfile> loadOrCreateProfile();
  Future<void> saveProfile(PlayerProfile profile);
}
