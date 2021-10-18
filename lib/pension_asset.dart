import 'package:uuid/uuid.dart';

class PensionAsset {

  late int no;
  late String id;
  late String item;
  late double buyPrice;
  late double currentPrice;
  late String tag;

  PensionAsset(int no) {
    this.no = no;
    this.id = Uuid().v4();
    this.item = '';
    this.buyPrice = 0;
    this.currentPrice = 0;
    this.tag = '';
  }

  static const String NO = 'no';
  static const String ID = 'id';
  static const String ITEM = 'item';
  static const String BUY_PRICE = 'buyPrice';
  static const String CURRENT_PRICE = 'currentPrice';
  static const String TAG = 'tag';

  double getTotalRevenue() {  // 수익
    return currentPrice - buyPrice;
  }

  String getEarningsRate() {  // 수익률
    return (getTotalRevenue() / buyPrice * 100).toStringAsFixed(1) + '%';
  }

  PensionAsset.fromJson(Map<String, dynamic> json) :
    no = json[NO],
    id = json[ID],
    item = json[ITEM],
    buyPrice = json[BUY_PRICE],
    currentPrice = json[CURRENT_PRICE],
    tag = json[TAG];

  Map<String, dynamic> toJson() => {
    NO : no,
    ID : id,
    ITEM : item,
    BUY_PRICE : buyPrice,
    CURRENT_PRICE : currentPrice,
    TAG : tag
  };
}