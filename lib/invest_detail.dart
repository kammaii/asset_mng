class InvestDetail {
  String currency;
  String buyAndSell;
  String item;
  double price;
  double amount;

  InvestDetail([this.currency = '원', this.buyAndSell = '매수', this.item = '', this.price = 0, this.amount = 0]);

  static const String CURRENCY = 'currency';
  static const String BUY_AND_SELL = 'buyAndSell';
  static const String ITEM = 'item';
  static const String PRICE = 'price';
  static const String AMOUNT = 'amount';

  InvestDetail.fromJson(Map<String, dynamic> json) :
        currency = json[CURRENCY],
        buyAndSell = json[BUY_AND_SELL],
        item = json[ITEM],
        price = json[PRICE],
        amount = json[AMOUNT];

  Map<String, dynamic> toJson() => {
    CURRENCY : currency,
    BUY_AND_SELL : buyAndSell,
    ITEM : item,
    PRICE : price,
    AMOUNT : amount
  };
}