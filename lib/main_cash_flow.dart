import 'dart:convert';
import 'package:asset_mng/auto_withdrawal.dart';
import 'package:asset_mng/cash_asset.dart';
import 'package:asset_mng/cash_detail.dart';
import 'package:asset_mng/invest_asset.dart';
import 'package:asset_mng/invest_detail.dart';
import 'package:asset_mng/sample_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class CashFlow extends StatefulWidget {
  const CashFlow({Key? key}) : super(key: key);

  @override
  _CashFlowState createState() => _CashFlowState();
}

class _CashFlowState extends State<CashFlow> {
  static const String CASH_ASSET = 'cashAsset';
  static const String CASH_DETAIL = 'cashDetail';
  static const String AUTO_WITHDRAWAL = 'autoWithdrawal';
  static const String INVEST_ASSET = 'investAsset';
  static const String INVEST_DETAIL = 'investDetail';

  String date = ' ';
  List<String> currencyDropdownList = ['원', '달러', '바트']; // todo: 입력받을 수 있는 기능 만들기
  List<String> buyAndSellDropdownList = ['매수', '매도'];

  double assetGoal = 100000000; // todo: 샘플값
  var f = NumberFormat('###,###,###,###.##');
  TextEditingController goalTextFieldController = TextEditingController();
  late String monthlyGoal;
  List<bool> isSelected = [false, true];
  static const double cardPadding = 30.0;
  static const double cardElevation = 5.0;

  late List<CashAsset> cashAssetList;
  late List<CashDetail> cashDetailList;
  late List<AutoWithdrawal> autoWithdrawalList;
  late List<InvestAsset> investAssetList;
  late List<InvestDetail> investDetailList;

  bool isAutoWithdrawalOpen = false;
  late String autoWithdrawalText;
  late double totalAutoWithdrawal;

  bool isInputMode = true;

  // 현금, 투자 자산 데이터 세팅하기
  void setAssetData() {
    cashAssetList = [];
    cashDetailList = [];
    investAssetList = [];
    investDetailList = [];
    autoWithdrawalList = [];

    if(isInputMode) {
      for(String cashData in SampleData().getLastCashAssetJson()) {
        cashAssetList.add(CashAsset.fromJson(jsonDecode(cashData)));
      }
      for(String investAsset in SampleData().getLastInvestAssetJson()) {
        investAssetList.add(InvestAsset.fromJson(jsonDecode(investAsset)));
      }
      cashDetailList.add(CashDetail());
      investDetailList.add(InvestDetail());

    } else {
      //todo: 입력한 월의 자료 세팅하기
      print('과거자료 보기 모드');
    }

    for(String autoTransferData in SampleData().getAutoWithdrawalJson()) {
      autoWithdrawalList.add(AutoWithdrawal.fromJson(jsonDecode(autoTransferData)));
    }
  }

  void setAutoTransferBtn() {
    isAutoWithdrawalOpen ? autoWithdrawalText = '저장' : autoWithdrawalText = '열기';
    totalAutoWithdrawal = 0;
    for(AutoWithdrawal autoWithdrawal in autoWithdrawalList) {
      totalAutoWithdrawal += autoWithdrawal.amount;
    }
  }


  @override
  Widget build(BuildContext context) {
    if(isInputMode) {
      monthlyGoal = f.format(SampleData().monthlyGoal/10000);
      goalTextFieldController.addListener(() {
        monthlyGoal = goalTextFieldController.text;
      });

    } else {
    }

    setAssetData();
    setAutoTransferBtn();


    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // todo: 새 데이터 입력하기
                  },
                  child: Text('입력하기')),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text('년/월: '),
                SizedBox(width: 20),
                getDropDownButton(date, SampleData().dateList, (newValue) => date = newValue),
                SizedBox(width: 20),
                Visibility(
                  visible: isInputMode,
                  child: Container(
                    width: 70,
                    height: 30,
                    alignment: Alignment.center,
                    child: TextField(
                      decoration: new InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(
                            bottom: 15
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text('목표: ${f.format(SampleData().lastGoalAsset + SampleData().monthlyGoal)} 원 (월'),
                SizedBox(width: 10),
                Container(
                  width: 70,
                  height: 30,
                  alignment: Alignment.center,
                  child: TextField(
                    decoration: new InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                        bottom: 15
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 5),
                Text('만원)'),
                SizedBox(width: 20),
                ElevatedButton(
                  child: Text('저장'),
                  onPressed: () {
                    // todo: monthlyGoal 저장하기
                  },
                ),
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
                    Text('현금현황', textScaleFactor: 2),
                    makeTable(CASH_ASSET),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getToggleButton('현금내역'),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          makeTable(CASH_DETAIL),
                          SizedBox(height: 20),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                            onPressed: () {
                              setState(() {
                                cashDetailList.add(CashDetail());
                              });
                            },
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(width: 200),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('자동이체', textScaleFactor: 2),
                          SizedBox(width: 20),
                          ElevatedButton(
                            child: Text(autoWithdrawalText),
                            onPressed: () {
                              if(isAutoWithdrawalOpen) {
                                //todo: 자동이체 저장하기
                                isAutoWithdrawalOpen = false;
                              } else {
                                isAutoWithdrawalOpen = true;
                              }
                              setState(() {});
                            },
                          ),
                          SizedBox(width: 20),
                          Text('(' + f.format(totalAutoWithdrawal) + ' 원)'),
                        ],
                      ),
                      Visibility(
                        visible: isAutoWithdrawalOpen,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            makeTable(AUTO_WITHDRAWAL),
                            SizedBox(height: 20),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                              onPressed: () {
                                setState(() {
                                  autoWithdrawalList.add(AutoWithdrawal());
                                });
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
            Card(
              elevation: cardElevation,
              child: Padding(
                padding: const EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('투자현황', textScaleFactor: 2),
                    makeTable(INVEST_ASSET),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getToggleButton('투자내역'),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      makeTable(INVEST_DETAIL),
                      SizedBox(height: 20),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                        onPressed: () {
                          setState(() {
                            investDetailList.add(InvestDetail());
                          });
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataTable makeTable(String type) {
    List<DataColumn> dataColumn = [];
    List<DataRow> dataRow = [];

    switch (type) {
      case CASH_ASSET :
        List<String> columns = ['통화','총액','증감','환율'];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(cashAssetList.length, (index) =>
          DataRow(
            cells: [
              DataCell(Text(cashAssetList[index].currency)),
              DataCell(Text(f.format(cashAssetList[index].amount))),
              DataCell(Text(f.format(cashAssetList[index].amount))), // todo: 환율 및 현금변동내역 반영할 것
              DataCell(Text(f.format(cashAssetList[index].exchangeRate))),
            ]
          )
        );
        break;

      case CASH_DETAIL :
        List<String> columns = ['통화','내용','금액', ''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(cashDetailList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getDropDownButton(cashDetailList[index].currency, currencyDropdownList, (newValue) => cashDetailList[index].currency = newValue)),
                  DataCell(getTextField(cashDetailList[index].item, (newValue) => cashDetailList[index].item = newValue)),
                  DataCell(getTextField(cashDetailList[index].amount, (newValue) => cashDetailList[index].amount = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(IconButton(
                    onPressed: (){
                      setState(() {
                        cashDetailList.removeAt(index);
                      });
                    },
                    icon: Icon(Icons.cancel_outlined, color: Colors.red))
                  )
                ]
            )
        );
        break;

      case AUTO_WITHDRAWAL :
        List<String> columns = ['내용','금액', ''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(autoWithdrawalList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getTextField(autoWithdrawalList[index].item, (newValue) => autoWithdrawalList[index].item = newValue)),
                  DataCell(getTextField(autoWithdrawalList[index].amount, (newValue) => autoWithdrawalList[index].amount = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(IconButton(
                      onPressed: (){
                        setState(() {
                          autoWithdrawalList.removeAt(index);
                        });
                      },
                      icon: Icon(Icons.cancel_outlined, color: Colors.red))
                  )
                ]
            )
        );
        break;

      case INVEST_ASSET :
        List<String> columns = ['통화','종목','매수가','현재가', '수량', '매입총액', '평가액' ,'수익', '수익률', '수익증가율', '태그'];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(investAssetList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(Text(investAssetList[index].currency)),
                  DataCell(Text(investAssetList[index].item)),
                  DataCell(Text(f.format(investAssetList[index].buyPrice))),
                  DataCell(Text(f.format(investAssetList[index].currentPrice))),
                  DataCell(Text(f.format(investAssetList[index].amount))),
                  DataCell(Text(f.format(investAssetList[index].getGrossPurchase()))),
                  DataCell(Text(f.format(investAssetList[index].getGrossValue()))),
                  DataCell(Text(f.format(investAssetList[index].getTotalRevenue()))),
                  DataCell(Text(investAssetList[index].getEarningsRate())),
                  DataCell(Text(investAssetList[index].getEarningsRate())),
                  DataCell(Text(investAssetList[index].tag)),
                ]
            )
        );
        break;

      case INVEST_DETAIL :
        List<String> columns = ['통화', '매매', '종목', '가격', '수량', ''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(investDetailList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getDropDownButton(investDetailList[index].currency, currencyDropdownList, (newValue) => investDetailList[index].currency = newValue)),
                  DataCell(getDropDownButton(investDetailList[index].buyAndSell, buyAndSellDropdownList, (newValue) => investDetailList[index].buyAndSell = newValue)),
                  DataCell(getTextField(investDetailList[index].item, (newValue) => investDetailList[index].item = newValue)),
                  DataCell(getTextField(investDetailList[index].price, (newValue) => investDetailList[index].price = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(getTextField(investDetailList[index].amount, (newValue) => investDetailList[index].amount = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(IconButton(
                      onPressed: (){
                        setState(() {
                          investDetailList.removeAt(index);
                        });
                      },
                      icon: Icon(Icons.cancel_outlined, color: Colors.red))
                  )
                ]
            )
        );
        break;
    }

    return DataTable(
      headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
      columns: dataColumn,
      rows: dataRow,
    );
  }

  TextField getTextField(dynamic data, Function(String) function) {
    FocusNode focusNode = FocusNode();
    focusNode.addListener(() {
      if(!focusNode.hasFocus) {
        setState(() {});
      }
    });
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
    return TextField(
      focusNode: focusNode,
      controller: textFieldController,
      inputFormatters: inputFormatter,
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


  Row getToggleButton(String title) {
    return Row(
      children: [
        Text(title, textScaleFactor: 2),
        SizedBox(width: 20),
        ToggleButtons(
          children: [
            Icon(Icons.upload_rounded),
            Icon(Icons.cancel_rounded)
          ],
          onPressed: (int index) {
            setState(() {
              for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                if (buttonIndex == index) {
                  isSelected[buttonIndex] = true;
                } else {
                  isSelected[buttonIndex] = false;
                }
              }
            });
          },
          isSelected: isSelected,
        )
      ],
    );
  }
}
