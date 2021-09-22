import 'package:uuid/uuid.dart';

class CashAsset {

  late int no;
  late String id;
  late String currency;
  late double amount;
  late double exchangeRate;
  late String assetType;

  //CashAsset([this.currency = '원', this.amount = 0, this.exchangeRate = 0, this.assetType = '']);
  CashAsset(int no) {
    this.no = no;
    this.id = Uuid().v4();
    this.currency = '원';
    this.amount = 0;
    this.exchangeRate = 1;
    this.assetType = '생활비';
  }

  CashAsset.clone(CashAsset asset) {
    this.no = asset.no;
    this.id = asset.id;
    this.currency = asset.currency;
    this.amount = asset.amount;
    this.exchangeRate = asset.exchangeRate;
    this.assetType = asset.assetType;
  }

  static const String NO = 'no';
  static const String ID = 'id';
  static const String CURRENCY = 'currency';
  static const String AMOUNT = 'amount';
  static const String EXCHANGE_RATE = 'exchangeRate';
  static const String ASSET_TYPE = 'assetType';

  CashAsset.fromJson(Map<String, dynamic> json) :
    no = json[NO],
    id = json[ID],
    currency = json[CURRENCY],
    amount = json[AMOUNT],
    exchangeRate = json[EXCHANGE_RATE],
    assetType = json[ASSET_TYPE];

  Map<String, dynamic> toJson() => {
    NO : no,
    ID : id,
    CURRENCY : currency,
    AMOUNT : amount,
    EXCHANGE_RATE : exchangeRate,
    ASSET_TYPE : assetType
  };

  // todo: 현재 환율 웹스크래핑으로 가져오기
  double getExchangeRate(String currency) {
    double exchangeRate = 0;
    return exchangeRate;
  }
}