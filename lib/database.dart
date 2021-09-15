import 'package:asset_mng/invest_asset.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cash_asset.dart';

class Database {
  static final Database _instance = Database.init();

  factory Database() {
    return _instance;
  }

  Database.init() {
    print('Database 초기화');
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const ASSET_MANAGER = 'assetManager';
  static const CASH_ASSET = 'cashAsset';
  static const INVEST_ASSET = 'investAsset';
  static const GOAL_ASSET = 'goalAsset';
  static const MONTHLY_GOAL = 'monthlyGoal';

  late BuildContext context;
  late String folder;
  late dynamic data;
  late String msg;
  List<String> monthList = [''];
  double monthGoal = 0;
  List<CashAsset> cashList = [];
  List<InvestAsset> investList = [];
  double assetGoal = 0;


  void saveAsset(BuildContext context, String date, double goalAsset, List<CashAsset> cashAsset, List<InvestAsset> investAsset) {
    this.context = context;

    // 현금자산 저장
    for(CashAsset cashAsset in cashAsset) {
      saveDB('$ASSET_MANAGER/$date/$CASH_ASSET', cashAsset.toJson(), 'Cash ${cashAsset.currency} added', false);
    }

    // 투자자산 저장
    for(InvestAsset investAsset in investAsset) {
      saveDB('$ASSET_MANAGER/$date/$INVEST_ASSET', investAsset.toJson(), 'Invest ${investAsset.item} added', false);
    }

    // 목표금액 저장
    saveDB('$ASSET_MANAGER/$date', {'$GOAL_ASSET' : goalAsset}, 'Goal $goalAsset 원 added', true);

    // 월목표금액 저장
    setMonthlyGoal(monthGoal);
  }


  Future<void> saveDB(String folder, dynamic data, String msg, bool isFinal) {
    CollectionReference ref = _firestore.collection(folder);
    return ref.add(data)
        .then((value) {
      if(isFinal) {
        showDialog(DialogType.SUCCES, 'Succeed save asset to DB');
      } else {
        print(msg);
      }
    })
        .catchError((e) => showDialog(DialogType.ERROR, 'Error + $e'));
  }

  AwesomeDialog showDialog(DialogType type, String title) {
    return AwesomeDialog(
      width: 500,
      context: context,
      dialogType: type,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
    )..show();
  }

  getLastMonthData() async {
    if(monthList.length < 2) {
      await getMonthList();
    }
    await getMonthGoal();
    await getSpecificMonthData(monthList.last);
  }

  getSpecificMonthData(String month) async {
    await getAssetGoal(month);
    await getCashAsset(month);
    await getInvestAsset(month);
  }

  Future<void> getMonthList() {
    CollectionReference ref = _firestore.collection(ASSET_MANAGER);
    return ref.get().then((QuerySnapshot querySnapshot) {
      if(querySnapshot.size != 0) {
        querySnapshot.docs.forEach((doc) {
          print(doc.id);
          monthList.add(doc.id);
        });
      } else {
        monthList = [];
      }
    }).catchError((e) => print('ERROR : $e'));
  }

  Future<void> getMonthGoal() async {
    monthGoal = 0;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    monthGoal = preferences.getDouble(MONTHLY_GOAL) ?? 0;
  }

  Future<void> getAssetGoal(String date) async {
    assetGoal = 0;
    CollectionReference ref = _firestore.collection(ASSET_MANAGER);
    return ref.doc(date).get().then((DocumentSnapshot snapshot) {
      if(snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        assetGoal = double.parse('${data[GOAL_ASSET]}');
      }
    });
  }

  Future<void> getCashAsset(String date) async {
    cashList = [];
    CollectionReference ref = _firestore.collection('$ASSET_MANAGER/$date/$CASH_ASSET');
    return ref.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) {
        Map<String, dynamic> data = element.data() as Map<String, dynamic>;
        cashList.add(CashAsset.fromJson(data));
      });
    });
  }

  Future<void> getInvestAsset(String date) async {
    investList = [];
    CollectionReference ref = _firestore.collection('$ASSET_MANAGER/$date/$INVEST_ASSET');
    return ref.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) {
        Map<String, dynamic> data = element.data() as Map<String, dynamic>;
        investList.add(InvestAsset.fromJson(data));
      });
    });
  }

  void setMonthlyGoal(double monthlyGoal) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setDouble(MONTHLY_GOAL, monthlyGoal);
  }

  Future<void> saveCashAsset(String date, CashAsset cashAsset) {
    DocumentReference ref = _firestore.doc('assetManager/$date/cashAsset/${cashAsset.currency}');
    return ref.set(cashAsset.toJson())
        .then((value) => print('Cash ${cashAsset.currency} added'))
        .catchError((e) => showDialog(DialogType.ERROR, 'Error + $e'));
  }

  Future<void> saveInvestAsset(String date, InvestAsset investAsset) {
    DocumentReference ref = _firestore.doc('assetManager/$date/cashAsset/${investAsset.item}');
    return ref.set(investAsset.toJson())
        .then((value) => print('Invest ${investAsset.item} added'))
        .catchError((e) => print('ERROR : $e'));
  }

  Future<void> saveGoalAsset(String date, double goalAsset) {
    DocumentReference ref = _firestore.doc('assetManager/$date');
    return ref.set(goalAsset)
        .then((value) => print('Goal $goalAsset 원 added'))
        .catchError((e) => print('ERROR : $e'));
  }
}
