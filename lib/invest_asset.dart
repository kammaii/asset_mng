import 'package:uuid/uuid.dart';

class InvestAsset {

  late String id;
  late String currency;
  late String item;
  late double buyPrice;
  late double currentPrice;
  late double quantity;
  late String assetType;
  late String tag;

  //InvestAsset([this.currency='원', this.item='', this.buyPrice=0, this.currentPrice=0, this.quantity=0, this.assetType='', this.tag='']);
  InvestAsset() {
    this.id = Uuid().v4();
    this.currency = '원';
    this.item = '';
    this.buyPrice = 0;
    this.currentPrice = 0;
    this.quantity = 0;
    this.assetType = '투자자산';
    this.tag = '';
  }

  static const String ID = 'id';
  static const String CURRENCY = 'currency';
  static const String ITEM = 'item';
  static const String BUY_PRICE = 'buyPrice';
  static const String CURRENT_PRICE = 'currentPrice';
  static const String QUANTITY = 'quantity';
  static const String ASSET_TYPE = 'assetType';
  static const String TAG = 'tag';

  void getCurrentPrice() {
    // todo: 웹스크래핑으로 현재값 가져와서 currentPrice 에 저장
  }

  double getGrossPurchase() { // 매입총액
    return buyPrice * quantity;
  }

  double getGrossValue() {  // 평가액
    return currentPrice * quantity;
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

  InvestAsset.fromJson(Map<String, dynamic> json) :
    id = json[ID],
    currency = json[CURRENCY],
    item = json[ITEM],
    buyPrice = json[BUY_PRICE],
    currentPrice = json[CURRENT_PRICE],
    quantity = json[QUANTITY],
    assetType = json[ASSET_TYPE],
    tag = json[TAG];

  Map<String, dynamic> toJson() => {
    ID : id,
    CURRENCY : currency,
    ITEM : item,
    BUY_PRICE : buyPrice,
    CURRENT_PRICE : currentPrice,
    QUANTITY : quantity,
    ASSET_TYPE : assetType,
    TAG : tag
  };
}