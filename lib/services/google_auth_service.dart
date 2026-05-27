import 'package:google_sign_in/google_sign_in.dart';

import '../models/googleauthresultmodel.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<GoogleAuthResult?> getGoogleData() async {
    await _googleSignIn.initialize(
      serverClientId:
          '966627803704-5efl3j3b1ap48gl1qmifi6rbhfq099ra.apps.googleusercontent.com',
    );

    final account = await _googleSignIn.authenticate(
      scopeHint: ['email', 'profile'],
    );

    final auth = account.authentication;

    if (auth.idToken == null) return null;

    return GoogleAuthResult(
      idToken: auth.idToken!,
      name: account.displayName,
      email: account.email,
      photoUrl: account.photoUrl,
    );
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }
}
