import 'package:rxdart/rxdart.dart';
import 'package:solomas/blocs/bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/participant_list_model.dart';
import 'package:solomas/model/road_king_queen_vote_model.dart';

class ParticipantsListBloc extends Bloc {

  final _publicSubject = PublishSubject<ParticipantListModel>();
  
  final _voteSubject = PublishSubject<RoadKingQueenVoteModel>();

  var _apiHelper = ApiHelper();

  Stream<ParticipantListModel> get participantsList => _publicSubject.stream;

  Future<dynamic> getParticipantList(String authToken, String contestId, String type) async {

    try {

      ParticipantListModel peopleModel = await _apiHelper.getParticipantsList(authToken, contestId, type);

      if (peopleModel.statusCode == 200) {
        
        _publicSubject.sink.add(peopleModel);
        
      } else {
        
        _publicSubject.sink.addError(peopleModel.data.toString());
      }

    } catch (error) {

      _publicSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> voteRoadKingQueen(String authToken, String reqBody) async {

    try {

      RoadKingQueenVoteModel voteModel = await _apiHelper.roadKingQueenVote(authToken, reqBody);
    
      if (voteModel.statusCode == 200) {
  
        _voteSubject.sink.add(voteModel);
      
      } else {
  
        _voteSubject.sink.addError(voteModel.data.toString());
      }
    
    } catch (error) {
  
      _voteSubject.sink.addError("Something Error");
    }
  }

  @override
  void dispose() {
    
    _publicSubject.close();

    _voteSubject.close();
  }
}