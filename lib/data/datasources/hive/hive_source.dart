import 'package:hive/hive.dart';
import 'package:loggy/loggy.dart';

import '../../../domain/entities/user.dart';
import '../../models/user_db.dart';
import '../i_local_auth_source.dart';
import '../shared_prefs/local_preferences.dart';

class HiveSource implements ILocalAuthSource {
  final _sharedPreferences = LocalPreferences();
  final Box _userBox = Hive.box('userDb');

  @override
  Future<String> getLoggedUser() async {
    try {
      final loggedUser = _userBox.get('loggedUser') as String?;
      return loggedUser ?? '';
    } catch (e) {
      logError('Error getting logged user: $e');
      return '';
    }
  }

  @override
  Future<User> getUserFromEmail(email) async {
    try {
      final userDb = _userBox.values.cast<UserDb?>().firstWhere(
            (user) => user?.email == email,
            orElse: () => null,
          );
      if (userDb != null) {
        return User(email: userDb.email, password: userDb.password);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      logError('Error getting user from email: $e');
      throw Exception('Error getting user from email');
    }
  }

  @override
  Future<bool> isLogged() async {
    try {
      final loggedUser = _userBox.get('loggedUser') as String?;
      return loggedUser != null && loggedUser.isNotEmpty;
    } catch (e) {
      logError('Error checking if user is logged: $e');
      return false;
    }
  }

  @override
  Future<void> logout() async {    
    try {
      await _userBox.delete('loggedUser');
      logInfo('User logged out successfully');
    } catch (e) {
      logError('Error logging out: $e');
    }
  }

  @override
  Future<void> setLoggedIn() async {
    await _sharedPreferences.storeData('logged', true);
  }

  @override
  Future<void> signup(email, password) async {
    try {
      final userDb = UserDb(email: email, password: password);
      await _userBox.put(email, userDb);
      logInfo('User signed up: $email');
    } catch (e) {
      logError('Error signing up user: $e');
      throw Exception('Error signing up user');
    }
  }
}
