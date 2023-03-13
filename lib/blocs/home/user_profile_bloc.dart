import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/user_profile_model.dart';

import '../bloc.dart';

class UserProfileBloc extends Object implements Bloc {
  
  final _publicSubject = PublishSubject<UserProfileModel>();
  
  var _apiHelper = ApiHelper();

  Stream<UserProfileModel> get userProfileList => _publicSubject.stream;

  Future<dynamic> getUserProfileData(String authToken, String id) async {

    try {

      UserProfileModel profileModel = await _apiHelper.getUserProfile(authToken, id);

      if (profileModel.statusCode == 200) {
  
        _publicSubject.sink.add(profileModel);

      } else {

        _publicSubject.sink.addError(profileModel.data.toString());
      }

    } catch (error) {

      _publicSubject.sink.addError("Something Error");
    }
  }
  
  @override
  void dispose() {

    _publicSubject.close();
  }
}