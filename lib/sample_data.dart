import 'dart:convert';

import 'auto_withdrawal.dart';
import 'cash_asset.dart';
import 'invest_asset.dart';

class SampleData {
  static final SampleData _instance = SampleData.init();

  factory SampleData() {
    return _instance;
  }

  SampleData.init() {
    print('Sample data 초기화');
  }

  List<String> dateList = [' ','21.07'];

  double lastGoalAsset = 100000000;
  double monthlyGoal = 5000000;


  List<String> getLastCashAssetJson() {
    List<String> sample = [];
    sample.add(jsonEncode(CashAsset('원', 300000000, 1, '생활비')));
    sample.add(jsonEncode(CashAsset('바트', 50000, 37, '생활비')));
    sample.add(jsonEncode(CashAsset('달러', 50000, 1065, '투자자산')));
    return sample;
  }

  List<String> getLastInvestAssetJson() {
    List<String> sample = [];
    sample.add(jsonEncode(InvestAsset('원', '삼성전자', 60000, 80000, 2000, '투자자산', '한국주식')));
    sample.add(jsonEncode(InvestAsset('원', '중국ETF', 10000, 15000, 1000, '투자자산', '중국주식')));
    sample.add(jsonEncode(InvestAsset('달러', 'NVDA', 60, 200, 100, '투자자산', '미국주식')));
    sample.add(jsonEncode(InvestAsset('원', '변액', 10000000, 11000000, 1, '연금자산', '변액연금')));
    sample.add(jsonEncode(InvestAsset('원', '연금펀드', 5000000, 6000000, 1, '연금자산', '연금펀드')));
    return sample;
  }

  List<String> getAutoWithdrawalJson() {
    List<String> sample = [];
    sample.add(jsonEncode(AutoWithdrawal('보험', 100000)));
    sample.add(jsonEncode(AutoWithdrawal('휴대폰', 50000)));
    sample.add(jsonEncode(AutoWithdrawal('계비', 10000)));
    return sample;
  }

  Map<String, double> thisExchangeRate = {
    '원' : 1,
    '달러' : 1100,
    '바트' : 38
  };

}

