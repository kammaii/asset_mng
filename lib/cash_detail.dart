class CashDetail {
  String currency;
  String title;
  double amount;

  CashDetail([this.currency = '원화', this.title = '', this.amount = 0]);

  static const String CURRENCY = 'currency';
  static const String TITLE = 'title';
  static const String AMOUNT = 'amount';

  CashDetail.fromJson(Map<String, dynamic> json) :
        currency = json[CURRENCY],
        title = json[TITLE],
        amount = json[AMOUNT];

  Map<String, dynamic> toJson() => {
    CURRENCY : currency,
    TITLE : title,
    AMOUNT : amount
  };
}