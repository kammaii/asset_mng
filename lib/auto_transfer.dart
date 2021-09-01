class AutoTransfer {
  String item;
  double amount;

  AutoTransfer([this.item = '', this.amount = 0]);

  static const String ITEM = 'item';
  static const String AMOUNT = 'amount';

  AutoTransfer.fromJson(Map<String, dynamic> json) :
        item = json[ITEM],
        amount = json[AMOUNT];

  Map<String, dynamic> toJson() => {
    ITEM : item,
    AMOUNT : amount
  };
}