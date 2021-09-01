class CashDetail {
  String currency;
  String item;
  double amount;

  CashDetail([this.currency = '원', this.item = '', this.amount = 0]);

  static const String CURRENCY = 'currency';
  static const String ITEM = 'item';
  static const String AMOUNT = 'amount';

  CashDetail.fromJson(Map<String, dynamic> json) :
        currency = json[CURRENCY],
        item = json[ITEM],
        amount = json[AMOUNT];

  Map<String, dynamic> toJson() => {
    CURRENCY : currency,
    ITEM : item,
    AMOUNT : amount
  };
}