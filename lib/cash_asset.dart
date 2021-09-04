
import 'dart:convert';

class CashAsset {

  late String currency;
  late double amount;
  late double exchangeRate;
  late String assetType;

  CashAsset([this.currency = '', this.amount = 0, this.exchangeRate = 0, this.assetType = '']);

  static const String CURRENCY = 'currency';
  static const String AMOUNT = 'amount';
  static const String EXCHANGE_RATE = 'exchangeRate';
  static const String ASSET_TYPE = 'assetType';

  CashAsset.fromJson(Map<String, dynamic> json) :
    currency = json[CURRENCY],
    amount = json[AMOUNT],
    exchangeRate = json[EXCHANGE_RATE],
    assetType = json[ASSET_TYPE];

  Map<String, dynamic> toJson() => {
    CURRENCY : currency,
    AMOUNT : amount,
    EXCHANGE_RATE : exchangeRate,
    ASSET_TYPE : assetType
  };

  List<String> getSample() {
    List<String> sample = [];
    sample.add(jsonEncode(CashAsset('원', 300000000, 1, '생활비')));
    sample.add(jsonEncode(CashAsset('바트', 50000, 37, '생활비')));
    sample.add(jsonEncode(CashAsset('달러', 50000, 1065, '투자자산')));
    return sample;
  }

  // todo: 현재 환율 웹스크래핑으로 가져오기
  double getExchangeRate(String currency) {
    double exchangeRate = 0;
    return exchangeRate;
  }
}