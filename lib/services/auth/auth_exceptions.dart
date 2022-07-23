// sign in exceptions:
class UserNotFoundAuthException implements Exception{

}

class WrongPasswordAuthException implements Exception{

}

// register exceptions:
class InvalidEmailAuthException implements Exception{

}

class WeakPasswordAuthException implements Exception{

}

class EmailAlreadyInUseAuthException implements Exception{

}

// generic exceptions:
class GenericAuthException implements Exception{

}

class UserNotSignedInAuthException implements Exception{

}