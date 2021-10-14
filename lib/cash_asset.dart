import 'package:uuid/uuid.dart';

class CashAsset {

  late int no;
  late String id;
  late String currency;
  late double amount;
  late double exchangeRate;

  CashAsset(int no) {
    this.no = no;
    this.id = Uuid().v4();
    this.currency = '원';
    this.amount = 0;
    this.exchangeRate = 1;
  }

  CashAsset.clone(CashAsset asset) {
    this.no = asset.no;
    this.id = asset.id;
    this.currency = asset.currency;
    this.amount = asset.amount;
    this.exchangeRate = asset.exchangeRate;
  }

  static const String NO = 'no';
  static const String ID = 'id';
  static const String CURRENCY = 'currency';
  static const String AMOUNT = 'amount';
  static const String EXCHANGE_RATE = 'exchangeRate';

  CashAsset.fromJson(Map<String, dynamic> json) :
    no = json[NO],
    id = json[ID],
    currency = json[CURRENCY],
    amount = json[AMOUNT],
    exchangeRate = json[EXCHANGE_RATE];

  Map<String, dynamic> toJson() => {
    NO : no,
    ID : id,
    CURRENCY : currency,
    AMOUNT : amount,
    EXCHANGE_RATE : exchangeRate
  };

  // todo: 현재 환율 웹스크래핑으로 가져오기
  double getExchangeRate(String currency) {
    double exchangeRate = 0;
    return exchangeRate;
  }
}