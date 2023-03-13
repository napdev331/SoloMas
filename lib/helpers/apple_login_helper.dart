import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;


abstract class AppleLoginListener {
  
  onAppleLogin(isLogin, email, fullName, user);
}

class AppleLoginHelper {

  AppleLoginListener _appleListener;

  AppleLoginHelper(this._appleListener) {

    appleLogIn();
  }
  
  Future appleLogIn() async {


    
      // final AuthorizationResult result = await AppleSignIn.performRequests([
      //
      //   AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      // ]);

      var uri=   Uri.parse(
        "https://api.solomasapp.com/api/auth/callbacks/sign_in_with_apple",
      );


      final credential =
      await SignInWithApple.getAppleIDCredential(

        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId:
          'com.solomas1.android',

          redirectUri:
          uri
          // For web your redirect URI needs to be the host of the "current page",
          // while for Android you will be using the API server that redirects back into your app via a deep link
          ,
        ),
        nonce: 'example-nonce',
        state: 'example-state',

      );

      // print(credential);

      // ignore: avoid_print
      print("cred"+credential.authorizationCode);
      print(credential);

      //   print("cred1"+credential.email);


      // This is the endpoint that will convert an authorization code obtained
      // via Sign in with Apple into a session in your system
      final signInWithAppleEndpoint = Uri(
        scheme: 'https',
        host:
        'api.solomasapp.com',
        path: '/api/auth/callbacks/sign_in_with_apple',
        queryParameters: <String, String>{
          'code': credential.authorizationCode,
          if (credential.givenName != null)
            'firstName': credential.givenName??"",
          if (credential.familyName != null)
            'lastName': credential.familyName.toString(),
          'useBundleId': 'true',
          if (credential.state != null)
            'state': credential.state.toString(),
        },
      );

      print("uri"+signInWithAppleEndpoint.toString());
      final session = await http.Client().post(
        signInWithAppleEndpoint,
      );

      var appleEmail,givenName, user= "";



      if(credential.email ==null)

      {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(credential.identityToken.toString());

        appleEmail = decodedToken['email'];

    }
      else {

        appleEmail = credential.email;


      }

      // if(result.credential.email == null) {
      //
      //   String yourToken = String.fromCharCodes(result.credential.identityToken);
      //
      //   Map<String, dynamic> decodedToken = JwtDecoder.decode(yourToken);
      //
      //   appleEmail = decodedToken['email'];
      //
      // } else {
      //
      //   appleEmail = result.credential.email;
      // }

      _appleListener.onAppleLogin(true, appleEmail,
          credential.givenName, appleEmail);


      // switch (result.status) {
      //
      //   case AuthorizationStatus.authorized:
      //
      //     var appleEmail = "";
      //
      //     if(result.credential.email == null) {
      //
      //       String yourToken = String.fromCharCodes(result.credential.identityToken);
      //
      //       Map<String, dynamic> decodedToken = JwtDecoder.decode(yourToken);
      //
      //       appleEmail = decodedToken['email'];
      //
      //     } else {
      //
      //       appleEmail = result.credential.email;
      //     }
      //
      //     _appleListener.onAppleLogin(true, appleEmail,
      //         result.credential.fullName.givenName, result.credential.user);
      //
      //     break;
      //
      //   case AuthorizationStatus.error:
      //
      //     _appleListener.onAppleLogin(false, null, null, null);
      //
      //     break;
      //
      //   case AuthorizationStatus.cancelled:
      //
      //     _appleListener.onAppleLogin(false, null, null, null);
      //
      //     break;
      // }

    // } else {
    //
    //   print('Apple SignIn is not available for your device');
    // }
  }
}