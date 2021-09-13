import 'dart:convert';
import 'package:asset_mng/cash_asset.dart';
import 'package:asset_mng/invest_asset.dart';
import 'package:asset_mng/sample_data.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'asset.dart';
import 'database.dart';

class CashFlow extends StatefulWidget {
  const CashFlow({Key? key}) : super(key: key);

  @override
  _CashFlowState createState() => _CashFlowState();
}

class _CashFlowState extends State<CashFlow> {
  String thisDate = '';
  String newDate = '';
  List<String> assetTypeDropdownList = ['투자자산', '연금자산', '생활비']; // todo: 입력받을 수 있는 기능 만들기
  List<String> currencyDropdownList = ['원', '달러', '바트']; // todo: 입력받을 수 있는 기능 만들기

  var f = NumberFormat('###,###,###,###.##');

  List<Asset> assetList = [];
  double lastMonthGoal = 0;
  double thisMonthGoal = 0;
  double monthlyGoal = 0;

  static const double cardPadding = 30.0;
  static const double cardElevation = 5.0;

  late List<Asset> cashAssetList;
  late List<Asset> investAssetList;

  bool isInputMode = true;
  bool isModeChanged = true;

  late double totalCash;
  late double totalInvest;


  // 현금, 투자 자산 데이터 세팅하기
  void setAssetData() {
    cashAssetList = [];
    investAssetList = [];

    if(isInputMode) {
      // 가장 최근의 데이터 가져오기
      for (Asset asset in assetList) {
        asset.isCash ? cashAssetList.add(asset) : investAssetList.add(asset);
      }

    } else {
      //todo: 날짜에 맞는 자산 데이터 가져오기

    }
  }

  // 현금, 투자 자산 총액 구하기
  void getTotalAsset() {
    totalCash = 0;
    totalInvest = 0;
    //Map<String, double> exchangeRate = Map();
    for(Asset cashAsset in cashAssetList) {
      totalCash += cashAsset.amount * cashAsset.exchangeRate;
      //exchangeRate[cashAsset.currency] = cashAsset.exchangeRate;
    }
    for(Asset investAsset in investAssetList) {
      totalInvest += (investAsset.getGrossValue() * investAsset.exchangeRate);
    }
  }


  @override
  void initState() {
    super.initState();
    getInitData();
  }

  void getInitData() async {
    await Database().getInitDate();
    setState(() {
      assetList = Database().lastAssetList;
      lastMonthGoal = Database().lastMonthGoal;
      monthlyGoal = Database().monthlyGoal;
      thisMonthGoal = lastMonthGoal + monthlyGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(isModeChanged) {
      setAssetData();
      isModeChanged = false;
    }
    getTotalAsset();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      thisDate = '';
                      newDate = '';
                      isInputMode = true;
                      isModeChanged = true;
                    });
                  },
                  child: Text('입력하기')),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text('년/월: '),
                SizedBox(width: 20),
                getDropDownButton(thisDate, Database().dateList, (newValue) {
                  thisDate = newValue;
                  isInputMode = false;
                  isModeChanged = true;
                }),
                SizedBox(width: 20),
                Visibility(
                  visible: isInputMode,
                  child: getTextField(newDate, (newValue) => newDate = newValue),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text('목표:'),
                SizedBox(width: 20),
                getTextField(thisMonthGoal, (newValue) => thisMonthGoal = double.parse(newValue.replaceAll(',', ''))),
                SizedBox(width: 20),
                Text('원  (월'),
                SizedBox(width: 10),
                getTextField(monthlyGoal, (newValue) {
                  double newGoal = double.parse(newValue.replaceAll(',', ''));
                  monthlyGoal = newGoal;
                  Database().setMonthlyGoal(newGoal);
                  thisMonthGoal = lastMonthGoal + newGoal;
                }),
                SizedBox(width: 5),
                Text('만원)'),
              ],
            ),
            SizedBox(height: 50),
            Card(
              elevation: cardElevation,
              child: Padding(
                padding: const EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('현금현황', textScaleFactor: 2),
                        SizedBox(width: 20),
                        Text('(총  ' + f.format(totalCash) + '  원)', textScaleFactor: 1.5)
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        makeTable(true),
                        SizedBox(height: 20),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              cashAssetList.add(Asset(true));
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            Card(
              elevation: cardElevation,
              child: Padding(
                padding: const EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('투자현황', textScaleFactor: 2),
                        SizedBox(width: 20),
                        Text('(총  ' + f.format(totalInvest) + '  원)', textScaleFactor: 1.5)
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        makeTable(false),
                        SizedBox(height: 20),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              investAssetList.add(Asset(false));
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  getDialog('저장하기', '저장할까요?', Colors.blue, (){
                    String date;
                    isInputMode? date = newDate : date = thisDate;
                    List<Asset> assetList = [];
                    for(Asset cashAsset in cashAssetList) {
                      assetList.add(cashAsset);
                    }
                    for(Asset investAsset in investAssetList) {
                      assetList.add(investAsset);
                    }
                    Database().saveAsset(context, date, thisMonthGoal, assetList);
                  }),
                  SizedBox(width: 20),
                  getDialog('삭제하기', '삭제할까요?', Colors.red, (){print('삭제');})
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton getDialog(String btnText, String title, Color color, Function f) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(primary: color),
        onPressed: () {
          AwesomeDialog(
              width: 500,
              context: context,
              dialogType: DialogType.INFO,
              animType: AnimType.BOTTOMSLIDE,
              title: title,
              btnOkText: '네',
              btnCancelText: '아니요',
              btnCancelOnPress: () {},
              btnOkOnPress: () {
                f();
              }
          )..show();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(btnText),
        )
    );
  }

  DataTable makeTable(bool isCash) {
    List<DataColumn> dataColumn = [];
    List<DataRow> dataRow = [];

    if(isCash) {
      List<String> columns = ['자산타입', '통화', '금액', '환율', '원화환산', ''];
      dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
      dataRow = List<DataRow>.generate(cashAssetList.length, (index) =>
          DataRow(
              cells: [
                DataCell(getDropDownButton(cashAssetList[index].assetType, assetTypeDropdownList, (newValue) => cashAssetList[index].assetType = newValue)),
                DataCell(getDropDownButton(cashAssetList[index].currency, currencyDropdownList, (newValue) => cashAssetList[index].currency = newValue)),
                DataCell(getTextField(cashAssetList[index].amount, (newValue) => cashAssetList[index].amount = double.parse(newValue.replaceAll(',', '')))),
                DataCell(getTextField(cashAssetList[index].exchangeRate, (newValue) => cashAssetList[index].exchangeRate = double.parse(newValue.replaceAll(',', '')))),
                DataCell(Text(f.format(cashAssetList[index].amount * cashAssetList[index].exchangeRate))),
                DataCell(IconButton(
                    onPressed: () {
                      setState(() {
                        cashAssetList.removeAt(index);
                      });
                    },
                    icon: Icon(Icons.cancel_outlined, color: Colors.red))
                )
              ]
          )
      );
    } else {
        List<String> columns = ['자산타입','통화','종목','매수가','현재가', '수량', '매입총액', '평가액' ,'수익', '수익률', '태그',''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(investAssetList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getDropDownButton(investAssetList[index].assetType, assetTypeDropdownList, (newValue) => investAssetList[index].assetType = newValue)),
                  DataCell(getDropDownButton(investAssetList[index].currency, currencyDropdownList, (newValue) => investAssetList[index].currency = newValue)),
                  DataCell(getTextField(investAssetList[index].item, (newValue) => investAssetList[index].item = newValue)),
                  DataCell(getTextField(investAssetList[index].buyPrice, (newValue) => investAssetList[index].buyPrice = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(getTextField(investAssetList[index].currentPrice, (newValue) => investAssetList[index].currentPrice = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(getTextField(investAssetList[index].amount, (newValue) => investAssetList[index].amount = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(Text(f.format(investAssetList[index].getGrossPurchase()))),
                  DataCell(Text(f.format(investAssetList[index].getGrossValue()))),
                  DataCell(Text(f.format(investAssetList[index].getTotalRevenue()))),
                  DataCell(Text(investAssetList[index].getEarningsRate())),
                  DataCell(getTextField(investAssetList[index].tag, (newValue) => investAssetList[index].tag = newValue)),
                  DataCell(IconButton(
                      onPressed: () {
                        setState(() {
                          investAssetList.removeAt(index);
                        });
                      },
                      icon: Icon(Icons.cancel_outlined, color: Colors.red))
                  )
                ]
            )
        );
    }

    return DataTable(
      headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
      columns: dataColumn,
      rows: dataRow,
    );
  }

  Container getTextField(dynamic data, Function(String) function) {
    TextEditingController textFieldController = TextEditingController();
    textFieldController.addListener(() {
      function(textFieldController.text);
    });
    List<TextInputFormatter> inputFormatter = [];
    if(data is String) {
      textFieldController.text = data;
    } else {
      textFieldController.text = f.format(data);
      inputFormatter.add(FilteringTextInputFormatter.digitsOnly);
    }
    return Container(
      height: 30,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 50),
        child: IntrinsicWidth(
          child: Focus(
            onFocusChange: (hasFocus) {
              if(!hasFocus) {
                setState(() {});
              }
            },
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.fromLTRB(15,0,15,15)
              ),
              textAlign: TextAlign.center,
              controller: textFieldController,
              inputFormatters: inputFormatter,
            ),
          ),
        ),
      ),
    );
  }

  DropdownButton getDropDownButton(String value, List<String> list, Function(String) f) {
    return DropdownButton(
        value: value,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 20,
        elevation: 10,
        onChanged: (dynamic newValue) {
          setState(() {
            f(newValue);
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList()
    );
  }
}
