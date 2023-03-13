import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/block_users_model.dart';

import '../bloc.dart';

class BlockedUsersBloc extends Object implements Bloc {
  
  BehaviorSubject<BlockedUserModel> _subject = BehaviorSubject<BlockedUserModel>();
  
  var _apiHelper = ApiHelper();
  
  BehaviorSubject<BlockedUserModel> get blockedUsersList => _subject;
  
  Future<dynamic> getUsers(String authToken) async {

    try {

      BlockedUserModel response = await _apiHelper.getBlockedUsers(authToken);
      
      if(response.statusCode == 200) {
        
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