import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/contest_list_model.dart';

import '../bloc.dart';

class ContestBloc extends Object implements Bloc {
  
  final _publicSubject = PublishSubject<ContestListModel>();
  
  var _apiHelper = ApiHelper();

  Stream<ContestListModel> get contestList => _publicSubject.stream;
  
  Future<dynamic> getContests(String authToken, String distance, String contestId) async {

    try {

      ContestListModel contestModel = await _apiHelper.getContestList(authToken, distance, contestId);

      if (contestModel.statusCode == 200) {

        _publicSubject.sink.add(contestModel);

      } else {

        _publicSubject.sink.addError(contestModel.data.toString());
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