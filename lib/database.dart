import 'package:asset_mng/cash_detail.dart';
import 'package:asset_mng/invest_asset.dart';
import 'package:asset_mng/pension_asset.dart';
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
  static const CASH_DETAIL = 'cashDetail';
  static const INVEST_ASSET = 'investAsset';
  static const PENSION_ASSET = 'pensionAsset';
  static const GOAL_ASSET = 'goalAsset';
  static const TOTAL_ASSET = 'totalAsset';
  static const TOTAL_CASH = 'totalCash';
  static const TOTAL_INVEST = 'totalInvest';
  static const TOTAL_PENSION = 'totalPension';
  static const MONTHLY_GOAL = 'monthlyGoal';
  static const MONTH = 'month';
  static const CURRENCY = 'currency';

  List<String> exMonthList = [
    '18.01','18.02','18.03','18.04','18.05','18.06','18.07','18.08','18.09','18.10','18.11','18.12',
    '19.01','19.02','19.03','19.04','19.05','19.06','19.07','19.08','19.09','19.10','19.11','19.12',
    '20.01','20.02','20.03','20.04','20.05','20.06','20.07','20.08','20.09','20.10','20.11','20.12',
    '21.01','21.02','21.03','21.04','21.05','21.06','21.07'];
  List<double> exGoalAssetList = [
    9000000,14000000,45923205,50923205,55235795,60235795,64517785,69517785,119517785,124517785,129517785,134517785,
    76767785,81767785,86767785,91767785,134980329,139680329,143779653,148779653,153779653,158779653,163779653,168779653,
    154279653,159279653,164279653,169279653,174279653,179279653,184279653,189279653,194279653,199279653,239279653,244279653,
    264279653,269279653,274279653,279279653,284279653,289279653,294279653];
  List<double> exTotalAssetList = [
    3826186,9787713,47787435,51765794,58295855,64872819,69278781,74031068,126280150,127644620,126206830,130884686,
    76554997,78539381,82139966,87128979,122125071,124990139,134629930,137338627,141721878,148081695,154970015,158397281,
    144469845,144238720,140033187,147623214,150694062,145263027,161805363,171679697,180354185,178129842,232475321,258727221,
    277673006,282072333,286895580,295978246,295323688,309521822,309296919];

  late BuildContext context;
  late String folder;
  late dynamic data;
  late String msg;
  List<String> monthList = [''];
  List<String> currencyList = [];
  List<double> totalAssetList = [];
  List<double> goalAssetList = [];
  List<double> totalCashAssetList = [];
  List<double> totalInvestAssetList = [];
  List<double> totalPensionAssetList = [];

  double monthGoal = 0;
  List<CashAsset> cashList = [];
  List<CashDetail> cashDetailList = [];
  List<InvestAsset> investList = [];
  List<PensionAsset> pensionList = [];
  Map<String, double> exchangeRate = {};
  double assetGoal = 0;

  late List<String> cashIdList;
  late List<String> cashDetailIdList;
  late List<String> investIdList;
  late List<String> pensionIdList;


  void saveAsset(BuildContext context,bool isInputMode,String month,double assetGoal,double monthGoal,List<CashAsset> cashAsset,List<CashDetail> cashDetail,List<InvestAsset> investAsset,List<PensionAsset> pensionAsset, double totalAsset,double totalCash,double totalInvest,double totalPension) {
    this.context = context;
    cashIdList = [];
    cashDetailIdList = [];
    investIdList = [];
    pensionIdList = [];

    // 현금자산 저장
    for(CashAsset cashAsset in cashAsset) {
      cashIdList.add(cashAsset.id);
      saveDB('$ASSET_MANAGER/$month/$CASH_ASSET/${cashAsset.id}', cashAsset.toJson(), 'Cash ${cashAsset.currency} added');
    }

    // 현금증감내역 저장
    for(CashDetail cashDetail in cashDetail) {
      cashDetailIdList.add(cashDetail.id);
      saveDB('$ASSET_MANAGER/$month/$CASH_DETAIL/${cashDetail.id}', cashDetail.toJson(), 'Cash detail ${cashDetail.note} added');
    }

    // 투자자산 저장
    for(InvestAsset investAsset in investAsset) {
      investIdList.add(investAsset.id);
      saveDB('$ASSET_MANAGER/$month/$INVEST_ASSET/${investAsset.id}', investAsset.toJson(), 'Invest ${investAsset.item} added');
    }

    // 연금자산 저장
    for(PensionAsset pensionAsset in pensionAsset) {
      pensionIdList.add(pensionAsset.id);
      saveDB('$ASSET_MANAGER/$month/$PENSION_ASSET/${pensionAsset.id}', pensionAsset.toJson(), 'Pension ${pensionAsset.item} added');
    }

    // 토탈금액 저장
    Map<String, double> totalData = {
      '$GOAL_ASSET':assetGoal,
      '$TOTAL_ASSET':totalAsset,
      '$TOTAL_CASH':totalCash,
      '$TOTAL_INVEST':totalInvest,
      '$TOTAL_PENSION':totalPension
    };
    saveDB('$ASSET_MANAGER/$month', totalData, 'Goal $assetGoal 원 added', isLast: true, isInput: isInputMode, month: month);

    // 월목표금액 저장
    setMonthlyGoal(monthGoal);
  }


  Future<void> saveDB(String folder, dynamic data, String msg, {bool? isLast, bool? isInput, String? month}) {
    DocumentReference ref = _firestore.doc(folder);
    return ref.set(data).then((value) {
      if(isLast!) {
        if(!isInput!) {
          checkRemovedDoc(month!);
        }
        print('Succeed save asset to DB');
        showDialog(DialogType.SUCCES, 'Succeed save asset');
        getInitList();
      } else {
        print(msg);
      }
    }).catchError((e) => print('Error + $e'));
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

  void checkRemovedDoc(String month) {
    for(CashAsset asset in cashList) {
      if(!cashIdList.contains(asset.id)) {
        deleteDoc('$ASSET_MANAGER/$month/$CASH_ASSET/${asset.id}');
      }
    }
    for(CashDetail asset in cashDetailList) {
      if(!cashDetailIdList.contains(asset.id)) {
        deleteDoc('$ASSET_MANAGER/$month/$CASH_DETAIL/${asset.id}');
      }
    }
    for(InvestAsset asset in investList) {
      if(!investIdList.contains(asset.id)) {
        deleteDoc('$ASSET_MANAGER/$month/$INVEST_ASSET/${asset.id}');
      }
    }
  }

  Future<void> deleteDoc(String path, {bool isLast = false}) {
    DocumentReference ref = _firestore.doc(path);
    if(isLast) {
      showDialog(DialogType.SUCCES, 'Succeed delete month');
      //todo: 페이지 다시 불러오기
      //getMonthList();
    }
    return ref.delete()
      .then((value) => print('$path deleted'))
      .catchError((e) => print('failed to delete doc : $path'));
  }

  void deleteMonth(BuildContext context, String month, List<CashAsset> cashList) {
    this.context = context;
    for(CashAsset asset in cashList) {
      deleteDoc('$ASSET_MANAGER/$month/$CASH_ASSET/${asset.id}');
    }
    for(CashDetail asset in cashDetailList) {
      deleteDoc('$ASSET_MANAGER/$month/$CASH_DETAIL/${asset.id}');
    }
    for(InvestAsset asset in investList) {
      deleteDoc('$ASSET_MANAGER/$month/$INVEST_ASSET/${asset.id}');
    }
    deleteDoc('$ASSET_MANAGER/$month', isLast: true);
  }

  getLastMonthData() async {
    await getMonthGoal();
    await getSpecificMonthData(monthList.last);
  }

  getSpecificMonthData(String month) async {
    await getAssetGoal(month);
    await getCashAsset(month);
    await getCashAssetDetail(month);
    await getInvestAsset(month);
    await getPensionAsset(month);
  }

  Future<void> getInitList() async {
    await getCurrencyList();
    monthList = [''];
    CollectionReference ref = _firestore.collection(ASSET_MANAGER);
    return ref.get().then((QuerySnapshot querySnapshot) {
      if(querySnapshot.size != 0) {
        List<Map<String, dynamic>> mapList = [];
        querySnapshot.docs.forEach((doc) {
          mapList.add({
            MONTH : double.parse(doc.id),
            TOTAL_ASSET : doc[TOTAL_ASSET],
            GOAL_ASSET : doc[GOAL_ASSET],
            TOTAL_CASH : doc[TOTAL_CASH],
            TOTAL_INVEST : doc[TOTAL_INVEST],
            TOTAL_PENSION : doc[TOTAL_PENSION],
          });
        });
        mapList.sort((a,b) => (a[MONTH]).compareTo(b[MONTH]));
        for(Map<String,dynamic> map in mapList) {
          monthList.add(map[MONTH].toStringAsFixed(2));
          totalAssetList.add(map[TOTAL_ASSET]);
          goalAssetList.add(map[GOAL_ASSET]);
          totalCashAssetList.add(map[TOTAL_CASH]);
          totalInvestAssetList.add(map[TOTAL_INVEST]);
          totalPensionAssetList.add(map[TOTAL_PENSION]);
        }
      }
    }).catchError((e) => print('ERROR : $e'));
  }


  Future<void> getMonthGoal() async {
    monthGoal = 0;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    monthGoal = preferences.getDouble(MONTHLY_GOAL) ?? 0;
  }

  Future<void> getCurrencyList() async {
    currencyList = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> list = preferences.getStringList(CURRENCY) ?? [];
    for(String str in list) {
      currencyList.add(str);
    }
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
        CashAsset asset = CashAsset.fromJson(data);
        cashList.add(asset);
        exchangeRate[asset.currency] = asset.exchangeRate;
      });
      cashList.sort((a,b) => a.no.compareTo(b.no));
    });
  }

  Future<void> getCashAssetDetail(String date) async {
    cashDetailList = [];
    CollectionReference ref = _firestore.collection('$ASSET_MANAGER/$date/$CASH_DETAIL');
    return ref.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) {
        Map<String, dynamic> data = element.data() as Map<String, dynamic>;
        cashDetailList.add(CashDetail.fromJson(data));
      });
      cashDetailList.sort((a,b) => a.no.compareTo(b.no));
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
      investList.sort((a,b) => a.no.compareTo(b.no));
    });
  }

  Future<void> getPensionAsset(String date) async {
    pensionList = [];
    CollectionReference ref = _firestore.collection('$ASSET_MANAGER/$date/$PENSION_ASSET');
    return ref.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) {
        Map<String, dynamic> data = element.data() as Map<String, dynamic>;
        pensionList.add(PensionAsset.fromJson(data));
      });
      pensionList.sort((a,b) => a.no.compareTo(b.no));
    });
  }


  void setMonthlyGoal(double monthlyGoal) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setDouble(MONTHLY_GOAL, monthlyGoal);
  }

  void setCurrencyList(List<String> currencyList) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setStringList(CURRENCY, currencyList);
    getCurrencyList();
  }

  Future<void> saveCashAsset(String date, CashAsset cashAsset) {
    DocumentReference ref = _firestore.doc('assetManager/$date/cashAsset/${cashAsset.currency}');
    return ref.set(cashAsset.toJson())
        .then((value) => print('Cash ${cashAsset.currency} added'))
        .catchError((e) => print('Error + $e'));
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
