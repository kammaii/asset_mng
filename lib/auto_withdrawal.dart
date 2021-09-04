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

  List<String> getSample() {
    List<String> sample = [];
    sample.add(jsonEncode(AutoWithdrawal('보험', 100000)));
    sample.add(jsonEncode(AutoWithdrawal('휴대폰', 50000)));
    sample.add(jsonEncode(AutoWithdrawal('계비', 10000)));
    return sample;
  }
}