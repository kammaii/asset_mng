import 'package:uuid/uuid.dart';

class CashDetail {

  late String id;
  late String currency;
  late double amount;
  late String note;

  static const String ID = 'id';
  static const String CURRENCY = 'currency';
  static const String AMOUNT = 'amount';
  static const String NOTE = 'note';

  CashDetail() {
    this.id = Uuid().v4();
    this.currency = '원';
  }

  CashDetail.fromJson(Map<String, dynamic> json) :
    id = json[ID],
    currency = json[CURRENCY],
    amount = json[AMOUNT],
    note = json[NOTE];

  Map<String, dynamic> toJson() => {
    ID : id,
    CURRENCY : currency,
    AMOUNT : amount,
    NOTE : note,
  };
}