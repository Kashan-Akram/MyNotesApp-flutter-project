import 'package:hehewhoknows/services/auth/auth_user.dart';

abstract class AuthProvider{
  AuthUser? get currentUser;
}