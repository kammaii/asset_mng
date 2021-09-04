
import 'dart:convert';

class InvestAsset {

  late String currency;
  late String item;
  late double buyPrice;
  late double currentPrice;
  late double amount;
  late String assetType;
  late String tag;

  InvestAsset([this.currency='', this.item='', this.buyPrice=0, this.currentPrice=0, this.amount=0, this.assetType='', this.tag='']);

  static const String CURRENCY = 'currency';
  static const String ITEM = 'item';
  static const String BUY_PRICE = 'buyPrice';
  static const String CURRENT_PRICE = 'currentPrice';
  static const String AMOUNT = 'amount';
  static const String ASSET_TYPE = 'assetType';
  static const String TAG = 'tag';

  void getCurrentPrice() {
    // todo: 웹스크래핑으로 현재값 가져와서 currentPrice 에 저장
  }

  double getGrossPurchase() { // 매입총액
    return buyPrice * amount;
  }

  double getGrossValue() {  // 평가액
    return currentPrice * amount;
  }

  double getTotalRevenue() {  // 수익
    return getGrossValue() - getGrossPurchase();
  }

  String getEarningsRate() {  // 수익률
    return (getTotalRevenue() / getGrossPurchase()).toStringAsFixed(2);
  }

  // String getEarningsGrowthRate() {  // 수익증가율
  //   return
  // }

  InvestAsset.fromJson(Map<String, dynamic> json) :
    currency = json[CURRENCY],
    item = json[ITEM],
    buyPrice = json[BUY_PRICE],
    currentPrice = json[CURRENT_PRICE],
    amount = json[AMOUNT],
    assetType = json[ASSET_TYPE],
    tag = json[TAG];

  Map<String, dynamic> toJson() => {
    CURRENCY : currency,
    ITEM : item,
    BUY_PRICE : buyPrice,
    CURRENT_PRICE : currentPrice,
    AMOUNT : amount,
    ASSET_TYPE : assetType,
    TAG : tag
  };

  List<String> getSample() {
    List<String> sample = [];
    sample.add(jsonEncode(InvestAsset('원', '삼성전자', 60000, 80000, 2000, '투자자산', '한국주식')));
    sample.add(jsonEncode(InvestAsset('원', '중국ETF', 10000, 15000, 1000, '투자자산', '중국주식')));
    sample.add(jsonEncode(InvestAsset('달러', 'NVDA', 60, 200, 100, '투자자산', '미국주식')));
    sample.add(jsonEncode(InvestAsset('원', '변액', 10000000, 11000000, 1, '연금자산', '변액연금')));
    sample.add(jsonEncode(InvestAsset('원', '연금펀드', 5000000, 6000000, 1, '연금자산', '연금펀드')));
    return sample;
  }
}