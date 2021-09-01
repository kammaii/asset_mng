
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
}