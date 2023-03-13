import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:solomas/blocs/bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/chat_individual_model.dart';

class ChatIndividualBloc with Bloc {

  var _apiHelper = ApiHelper();

  final _subject = PublishSubject<ChatIndividualModel>();

  Stream<ChatIndividualModel> get chatList => _subject.stream;

  Future<dynamic> getChatData(String authToken, String userId) async {

    try {

      ChatIndividualModel chatModel = await _apiHelper.getChatIndividual(authToken, userId);

      if (chatModel.statusCode == 200) {

        _subject.sink.add(chatModel);
      } else {
        _subject.sink.addError(chatModel.data.toString());
      }

    } catch (error) {

      _subject.sink.addError("Something Error");
    }
  }

  @override
  void dispose() {
    _subject.close();
  }
}