import 'package:uuid/uuid.dart';

class CashDetail {

  late int no;
  late String id;
  late String assetType;
  late String currency;
  late double amount;
  late String note;

  static const String NO = 'no';
  static const String ID = 'id';
  static const String ASSET_TYPE = 'assetType';
  static const String CURRENCY = 'currency';
  static const String AMOUNT = 'amount';
  static const String NOTE = 'note';

  CashDetail(int no) {
    this.no = no;
    this.id = Uuid().v4();
    this.assetType = '생활비';
    this.currency = '원';
    this.amount = 0;
    this.note = '';
  }

  CashDetail.fromJson(Map<String, dynamic> json) :
    no = json[NO],
    id = json[ID],
    assetType = json[ASSET_TYPE],
    currency = json[CURRENCY],
    amount = json[AMOUNT],
    note = json[NOTE];

  Map<String, dynamic> toJson() => {
    NO : no,
    ID : id,
    ASSET_TYPE : assetType,
    CURRENCY : currency,
    AMOUNT : amount,
    NOTE : note,
  };
}