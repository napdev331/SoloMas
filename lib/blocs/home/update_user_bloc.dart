import 'package:rxdart/rxdart.dart';
import 'package:solomas/blocs/bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/update_user_data_model.dart';

class UpdateUserBloc extends Object implements Bloc {
  BehaviorSubject<UpdateUserModel> _subject =
      BehaviorSubject<UpdateUserModel>();

  var _apiHelper = ApiHelper();

  BehaviorSubject<UpdateUserModel> get subject => _subject;

  Future<dynamic> updateUser(String authToken, String body) async {
    try {
      UpdateUserModel response =
          await _apiHelper.updateUserData(body, authToken);

      if (response.statusCode == 200) {
        _subject.sink.add(response);
      } else {
        return Future.error(response.data.toString());
      }
    } catch (error) {
      return Future.error("Something Error");
    }
  }

  @override
  void dispose() {
    _subject.close();
  }
}
