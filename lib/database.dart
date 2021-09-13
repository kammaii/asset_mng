import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'asset.dart';

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
  static const ASSET = 'asset';
  static const MONTHLY_GOAL = 'monthlyGoal';

  late BuildContext context;
  List<String> dateList = [];
  List<Asset> lastAssetList = [];
  double lastMonthGoal = 0;
  double monthlyGoal = 0;

  void saveAsset(BuildContext context, String date, double goalAsset, List<Asset> assetList) {
    this.context = context;

    // 자산 저장
    int count = 0;
    for(Asset asset in assetList) {
      bool isFinal;
      count == assetList.length-1 ? isFinal = true : isFinal = false;
      saveDB(date, asset, isFinal);
      count++;
    }
    
    // 월목표금액 저장
    setMonthlyGoal(monthlyGoal);
  }


  Future<void> saveDB(String date, Asset asset, bool isFinal) {
    CollectionReference ref = _firestore.collection('$ASSET_MANAGER/$date/$ASSET');
    return ref.doc('${asset.id}').set(asset.toJson()).then((value) {
          if(isFinal) {
            showDialog(DialogType.SUCCES, 'Succeed save asset to DB');
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

  Future<void> getInitDate() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    monthlyGoal = preferences.getDouble(MONTHLY_GOAL) ?? 0;
    dateList = [''];
    CollectionReference ref = _firestore.collection(ASSET_MANAGER);
    return ref.get().then((QuerySnapshot querySnapshot) async {
          if(querySnapshot.size != 0) {
            querySnapshot.docs.forEach((doc) {
              print(doc.id);
              dateList.add(doc.id);
            });
            await getLatestAsset();
            lastMonthGoal = lastAssetList[0].goalAsset;

          } else {
            dateList = [];
          }
        })
        .catchError((e) => print('ERROR : $e'));
  }

  Future<void> getLatestAsset() {
    lastAssetList = [];
    CollectionReference ref = _firestore.collection('$ASSET_MANAGER/${dateList[dateList.length-1]}/$ASSET');
    return ref.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) {
        lastAssetList.add(Asset.fromJson(jsonDecode(element.data().toString())));
      });
    });
  }

  void setMonthlyGoal(double monthlyGoal) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setDouble(MONTHLY_GOAL, monthlyGoal);
  }
}