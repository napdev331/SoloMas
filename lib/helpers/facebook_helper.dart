/*import 'dart:convert';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:http/http.dart' as http;*/


/*abstract class FbLoginListener {

  onFbLoginSuccess(isLogin, {profileData});
}*/

/*class FacebookHelper {

  FbLoginListener fbListener;

  FacebookHelper(this.fbListener) {

    init();
  }

  Future<Null> init() async {

    var facebookLogin = FacebookLogin();

    // facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;

        var facebookLoginResult = await facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email
    ]);

    switch (facebookLoginResult.status) {

      case FacebookLoginStatus.error:

        fbListener.onFbLoginSuccess(false);

        break;

      case FacebookLoginStatus.cancel:

        fbListener.onFbLoginSuccess(false);

        break;

      case FacebookLoginStatus.success:

        var graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,'
                'last_name,email,picture.height(200)&access_token=${facebookLoginResult
                .accessToken.token}'
        ));

        Map<String, dynamic> profile = json.decode(graphResponse.body);

        fbListener.onFbLoginSuccess(true, profileData: profile);

        break;
    }
  }
}*/

/* upper comment body was the comment on 21-july-2022....*/




// abstract class FbLoginListener {
//   onFbLoginSuccess(isLogin, {profileData, profileUrl});
// }
//
// class FacebookHelper {
//
//   FbLoginListener fbListener;
//
//   FacebookHelper(this.fbListener);
//
//   Future<dynamic> init() async {
//
//     var facebookLogin = FacebookLogin();
//
//     var facebookLoginResult = await facebookLogin.logIn(permissions: [
//       FacebookPermission.publicProfile,
//       FacebookPermission.email
//     ]);
//
//     switch (facebookLoginResult.status) {
//
//       case FacebookLoginStatus.error:
//
//         fbListener.onFbLoginSuccess(false);
//
//         break;
//
//       case FacebookLoginStatus.success:
//
//         var graphResponse = await http.get(Uri.parse(
//             'https://graph.facebook.com/v2.12/me?fields=name,first_name,'
//                 'last_name,email,picture.height(200)&access_token='
//                 '${facebookLoginResult.accessToken.token}'));
//
//         Map<String, dynamic> profile = json.decode(graphResponse.body);
//
//         String profileUrl = "";
//
//         if (profile["picture"] != null &&
//             profile["picture"]["data"] != null &&
//             profile["picture"]["data"]["url"] != null) {
//           profileUrl = profile["picture"]["data"]["url"];
//         }
//
//         fbListener.onFbLoginSuccess(true,
//             profileData: profile, profileUrl: profileUrl);
//
//         break;
//
//       case FacebookLoginStatus.cancel:
//
//         fbListener.onFbLoginSuccess(false);
//
//         break;
//     }
//   }
// }

