import 'dart:convert';
import 'package:asset_mng/cash_asset.dart';
import 'package:asset_mng/invest_asset.dart';
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
  static const String INVEST_ASSET = 'investAsset';

  String date = '';
  List<String> currencyDropdownList = ['원', '달러', '바트']; // todo: 입력받을 수 있는 기능 만들기

  var f = NumberFormat('###,###,###,###.##');
  TextEditingController goalTextFieldController = TextEditingController();
  late String monthlyGoal;
  static const double cardPadding = 30.0;
  static const double cardElevation = 5.0;

  late List<CashAsset> cashAssetList;
  late List<InvestAsset> investAssetList;

  bool isInputMode = true;

  // 현금, 투자 자산 데이터 세팅하기
  void setAssetData() {
    cashAssetList = [];
    investAssetList = [];

    for(String cashData in SampleData().getLastCashAssetJson()) {
      cashAssetList.add(CashAsset.fromJson(jsonDecode(cashData)));
    }
    for(String investAsset in SampleData().getLastInvestAssetJson()) {
      investAssetList.add(InvestAsset.fromJson(jsonDecode(investAsset)));
    }
  }


  @override
  Widget build(BuildContext context) {
    monthlyGoal = f.format(SampleData().monthlyGoal/10000);
    goalTextFieldController.addListener(() {
      monthlyGoal = goalTextFieldController.text;
    });
    setAssetData();

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
                    SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        makeTable(CASH_ASSET),
                        SizedBox(height: 20),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              cashAssetList.add(CashAsset());
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
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
                    SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        makeTable(INVEST_ASSET),
                        SizedBox(height: 20),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              investAssetList.add(InvestAsset());
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
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
        List<String> columns = ['통화','금액','환율','원화환산',''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(cashAssetList.length, (index) =>
          DataRow(
            cells: [
              DataCell(getDropDownButton(cashAssetList[index].currency, currencyDropdownList, (newValue) => cashAssetList[index].currency = newValue)),
              DataCell(getTextField(cashAssetList[index].amount, (newValue) => cashAssetList[index].amount = double.parse(newValue.replaceAll(',', '')))),
              DataCell(Text(f.format(cashAssetList[index].exchangeRate))), // todo: 환율 및 현금변동내역 반영할 것
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
        break;

      case INVEST_ASSET :
        List<String> columns = ['통화','종목','매수가','현재가', '수량', '매입총액', '평가액' ,'수익', '수익률', '태그',''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(investAssetList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getDropDownButton(investAssetList[index].currency, currencyDropdownList, (newValue) => investAssetList[index].currency = newValue)),
                  DataCell(getTextField(investAssetList[index].item, (newValue) => investAssetList[index].item = newValue)),
                  DataCell(getTextField(investAssetList[index].buyPrice, (newValue) => investAssetList[index].buyPrice = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(getTextField(investAssetList[index].currentPrice, (newValue) => investAssetList[index].currentPrice = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(getTextField(investAssetList[index].quantity, (newValue) => investAssetList[index].quantity = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(Text(f.format(investAssetList[index].getGrossPurchase()))),
                  DataCell(Text(f.format(investAssetList[index].getGrossValue()))),
                  DataCell(Text(f.format(investAssetList[index].getTotalRevenue()))),
                  DataCell(Text(investAssetList[index].getEarningsRate())),
                  DataCell(getTextField(investAssetList[index].tag, (newValue) => investAssetList[index].tag = newValue)),
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
}
