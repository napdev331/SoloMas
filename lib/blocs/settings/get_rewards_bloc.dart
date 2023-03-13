import 'package:rxdart/rxdart.dart';
import 'package:solomas/blocs/bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/buy_reward_item_model.dart';
import 'package:solomas/model/reward_items_model.dart';

class GetRewardsBloc extends Object implements Bloc {

  BehaviorSubject<RewardItemModel> _subject = BehaviorSubject<RewardItemModel>();
  
  BehaviorSubject<BuyRewardItemModel> _buyItemSubject = BehaviorSubject<BuyRewardItemModel>();

  var _apiHelper = ApiHelper();

  BehaviorSubject<RewardItemModel> get rewardItemList => _subject;
  
  BehaviorSubject<BuyRewardItemModel> get buyRewardItemList => _buyItemSubject;

  Future<dynamic> getRewardItems(String authToken) async {

    try {

      RewardItemModel response = await _apiHelper.getRewardItems(authToken);

      if(response.statusCode == 200) {

        _subject.sink.add(response);

      } else {

        return Future.error(response.data.toString());
      }

    } catch (error) {

      return Future.error("Something Error");
    }
  }

  Future<dynamic> buyRewardItem(String body, String authToken) async {

    try {

      BuyRewardItemModel changedModel = await _apiHelper.buyItems(body, authToken);

      if(changedModel.statusCode == 200) {

        buyRewardItemList.sink.add(changedModel);

      } else {

        buyRewardItemList.sink.addError(changedModel.data.toString());
      }

    } catch (error) {

      buyRewardItemList.sink.addError("Something Error");
    }
  }

  @override
  void dispose() {

    _subject.close();

    _buyItemSubject.close();
  }
}