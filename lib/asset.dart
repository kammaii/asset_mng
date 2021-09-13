import 'package:uuid/uuid.dart';

class Asset {

  late String id; // 공통
  late bool isCash; // 공통
  String currency = '원'; // 공통
  String assetType = '투자자산'; // 공통
  double amount = 0; // 공통
  double goalAsset = 0; // 공통
  double exchangeRate = 1; // 공통
  String item = ''; // 투자
  double buyPrice = 0; // 투자
  double currentPrice = 0; // 투자
  String tag = ''; // 투자

  static const String ID = 'id';
  static const String IS_CASH = 'isCash';
  static const String GOAL_ASSET = 'goalAsset';
  static const String CURRENCY = 'currency';
  static const String AMOUNT = 'amount';
  static const String EXCHANGE_RATE = 'exchangeRate';
  static const String ASSET_TYPE = 'assetType';
  static const String ITEM = 'item';
  static const String BUY_PRICE = 'buyPrice';
  static const String CURRENT_PRICE = 'currentPrice';
  static const String TAG = 'tag';

  Asset(this.isCash) {
    this.id = Uuid().v4();
  }

  Asset.fromJson(Map<String, dynamic> json) :
    id = json[ID],
    currency = json[CURRENCY],
    amount = json[AMOUNT],
    exchangeRate = json[EXCHANGE_RATE],
    item = json[ITEM],
    buyPrice = json[BUY_PRICE],
    currentPrice = json[CURRENT_PRICE],
    assetType = json[ASSET_TYPE],
    isCash = json[IS_CASH],
    goalAsset = json[GOAL_ASSET],
    tag = json[TAG];

  Map<String, dynamic> toJson() => {
    ID : id,
    CURRENCY : currency,
    AMOUNT : amount,
    EXCHANGE_RATE : exchangeRate,
    ITEM : item,
    BUY_PRICE : buyPrice,
    CURRENT_PRICE : currentPrice,
    ASSET_TYPE : assetType,
    IS_CASH : isCash,
    GOAL_ASSET : goalAsset,
    TAG : tag
  };

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
    return (getTotalRevenue() / getGrossPurchase() * 100).toStringAsFixed(1) + '%';
  }

// String getEarningsGrowthRate() {  // 수익증가율
//   return
// }
}