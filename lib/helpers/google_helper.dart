import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleLoginListener {
  onGoogleLogin(isLogin, googleId, email, fullName, photoUrl);
}

class GoogleHelper {
  GoogleLoginListener _googleListener;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  GoogleHelper(this._googleListener) {
    init();
  }

  Future<void> init() async {
    try {
      logout();

      var googleSignIn = await _googleSignIn.signIn();

      _googleListener.onGoogleLogin(true, googleSignIn?.id, googleSignIn?.email,
          googleSignIn?.displayName, googleSignIn?.photoUrl);
    } catch (error) {
      _googleListener.onGoogleLogin(false, null, null, null, null);

      print(error);
    }
  }

  void logout() {
    _googleSignIn.signOut();
  }
}
