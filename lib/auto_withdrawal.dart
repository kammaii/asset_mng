import 'dart:convert';

class AutoWithdrawal {
  String item;
  double amount;

  AutoWithdrawal([this.item = '', this.amount = 0]);

  static const String ITEM = 'item';
  static const String AMOUNT = 'amount';

  AutoWithdrawal.fromJson(Map<String, dynamic> json) :
        item = json[ITEM],
        amount = json[AMOUNT];

  Map<String, dynamic> toJson() => {
    ITEM : item,
    AMOUNT : amount
  };
}