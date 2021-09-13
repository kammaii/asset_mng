import 'dart:convert';
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

  List<String> dateList = ['','21.07'];

  double lastGoalAsset = 100000000;
  double monthlyGoal = 5000000;


  List<String> getLastCashAssetJson() {
    List<String> sample = [];
    CashAsset cashAsset = CashAsset();
    cashAsset.currency = '원';
    cashAsset.amount = 10000;
    cashAsset.exchangeRate = 1;
    cashAsset.assetType = '생활비';
    sample.add(jsonEncode(cashAsset));
    // sample.add(jsonEncode(CashAsset('바트', 50000, 37, '생활비')));
    // sample.add(jsonEncode(CashAsset('달러', 50000, 1065, '투자자산')));
    return sample;
  }

  List<String> getLastInvestAssetJson() {
    List<String> sample = [];
    InvestAsset investAsset = InvestAsset();
    investAsset.currency = '원';
    investAsset.item = '삼성전자';
    investAsset.buyPrice = 60000;
    investAsset.currentPrice = 80000;
    investAsset.quantity = 2000;
    investAsset.assetType = '투자자산';
    investAsset.tag = '한국주식';
    sample.add(jsonEncode(investAsset));
    // sample.add(jsonEncode(InvestAsset('원', '중국ETF', 10000, 15000, 1000, '투자자산', '중국주식')));
    // sample.add(jsonEncode(InvestAsset('달러', 'NVDA', 60, 200, 100, '투자자산', '미국주식')));
    // sample.add(jsonEncode(InvestAsset('원', '변액', 10000000, 11000000, 1, '연금자산', '변액연금')));
    // sample.add(jsonEncode(InvestAsset('원', '연금펀드', 5000000, 6000000, 1, '연금자산', '연금펀드')));
    return sample;
  }
}

