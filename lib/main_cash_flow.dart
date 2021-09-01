import 'dart:convert';
import 'package:asset_mng/auto_transfer.dart';
import 'package:asset_mng/cash_asset.dart';
import 'package:asset_mng/cash_detail.dart';
import 'package:asset_mng/invest_asset.dart';
import 'package:asset_mng/invest_detail.dart';
import 'package:flutter/material.dart';
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
  static const String AUTO_TRANSFER = 'autoTransfer';
  static const String INVEST_ASSET = 'investAsset';
  static const String INVEST_DETAIL = 'investDetail';



  late String date;
  List<String> dateDropdownList = ['', '1', '2', '3', '4'];  // todo: 년/월 데이터 받기
  List<String> currencyDropdownList = ['원', '달러', '바트']; // todo: 입력받을 수 있는 기능 만들기
  List<String> buyAndSellDropdownList = ['매수', '매도'];

  double assetGoal = 100000000; // todo: 샘플값
  var f = NumberFormat('###,###,###,###.##');
  TextEditingController goalTextFieldController = TextEditingController();
  late String monthlyGoal;
  List<bool> isSelected = [false, true];
  static const double cardPadding = 30.0;
  static const double cardElevation = 5.0;

  List<CashAsset> cashAssetList = [];
  List<CashDetail> cashDetailList = [];
  List<AutoTransfer> autoTransferList = [];
  List<InvestAsset> investAssetList = [];
  List<InvestDetail> investDetailList = [];



  List<String> cashJsonList = [ // todo: 샘플 현금 현황 (실재 DB에서 받는 데이터 형태)
    jsonEncode(CashAsset('원', 1000000, 1, '생활비')),
    jsonEncode(CashAsset('바트', 5555, 37, '생활비')),
    jsonEncode(CashAsset('달러', 3000, 1065, '투자자산'))
  ];

  List<double> exchangeRate = [1, 38.5, 1070.4]; // todo: 현재 환율 웹스크래핑으로 가져오기


  @override
  void initState() {
    super.initState();
    date = '';
    monthlyGoal = ""; // todo: 저장된 값 가져오기
    goalTextFieldController.addListener(() {
      monthlyGoal = goalTextFieldController.text;
    });

    // json 리스트를 CashAsset 리스트로 변경
    //todo: date를 선택했을 때 현금,투자 내역을 받아서 cashDetailList 에 넣기
    for(String cashData in cashJsonList) {
      cashAssetList.add(CashAsset.fromJson(jsonDecode(cashData)));
    }

    if(cashDetailList.isEmpty) {
      cashDetailList.add(CashDetail());
    }
    if(autoTransferList.isEmpty) {
      autoTransferList.add(AutoTransfer());
    }
    if(investAssetList.isEmpty) {
      investAssetList.add(InvestAsset());
    }
    if(investDetailList.isEmpty) {
      investDetailList.add(InvestDetail());
    }
  }


  @override
  Widget build(BuildContext context) {
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
                getDropDownButton(date, dateDropdownList, (newValue) => date = newValue)
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text('목표: ${f.format(assetGoal)} 원 (월'),
                SizedBox(width: 10),
                Container(
                  width: 70,
                  height: 30,
                  alignment: Alignment.center,
                  child: TextField(
                    decoration: new InputDecoration(
                      labelText: monthlyGoal,
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
              padding: const EdgeInsets.only(left: 100),
              child: Row(
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
                            child: Text('저장'),
                            onPressed: () {
                              // todo: 자동이체 저장하기
                            },
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          makeTable(AUTO_TRANSFER),
                          SizedBox(height: 20),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                            onPressed: () {
                              setState(() {
                                //cashDetailList.add(CashDetail());
                              });
                            },
                          )
                        ],
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
              padding: const EdgeInsets.only(left: 100.0),
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
              DataCell(Text(f.format(exchangeRate[index]))),
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
                  DataCell(getTextField(data: cashDetailList[index].item)),
                  DataCell(getTextField(data: cashDetailList[index].amount)),
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

      case AUTO_TRANSFER :
        List<String> columns = ['내용','금액', ''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(autoTransferList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getTextField(data: autoTransferList[index].item)),
                  DataCell(getTextField(data: autoTransferList[index].amount)),
                  DataCell(IconButton(
                      onPressed: (){
                        setState(() {
                          autoTransferList.removeAt(index);
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
                  DataCell(getTextField(data: investDetailList[index].item)),
                  DataCell(getTextField(data: investDetailList[index].price)),
                  DataCell(getTextField(data: investDetailList[index].amount)),
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

  TextField getTextField({dynamic data}) {
    TextEditingController textFieldController = TextEditingController();
    textFieldController.addListener(() {
      setState(() {
        print(textFieldController.text);
        print(textFieldController.text.runtimeType);
        data = textFieldController.text;
      });
    });
    if(data != null) {
      //data.runtimeType is String ? textFieldController.text = data : textFieldController.text = f.format(data); //todo: 이거 왜 안되지?
      data.runtimeType is String ? textFieldController.text = data : print('not String');
    }
    return TextField(
      controller: textFieldController,
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
