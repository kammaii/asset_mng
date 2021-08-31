import 'dart:convert';
import 'package:asset_mng/cash_asset.dart';
import 'package:asset_mng/cash_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashFlow extends StatefulWidget {
  const CashFlow({Key? key}) : super(key: key);

  @override
  _CashFlowState createState() => _CashFlowState();
}

class _CashFlowState extends State<CashFlow> {
  static const String CASH_REPORT = 'cashReport';
  static const String CASH_DETAIL = 'cashDetail';
  late String date;
  List<String> dateDropdownList = ['', '1', '2', '3', '4'];  // todo: 년/월 데이터 받기
  List<String> currencyDropdownList = ['원화', '달러', '바트']; // todo: 입력받을 수 있는 기능 만들기
  double assetGoal = 100000000; // todo: 샘플값
  var f = NumberFormat('###,###,###,###.##');
  final textFieldController = TextEditingController();
  late String monthlyGoal;
  List<bool> isSelected = [false, true];

  List<CashAsset> cashDataList = [];
  List<CashDetail> cashDetailList = [];

  List<String> cashJsonList = [ // todo: 샘플 현금 현황 (실재 DB에서 받는 데이터 형태)
    jsonEncode(CashAsset('원화', 1000000, 1, '생활비')),
    jsonEncode(CashAsset('바트', 5555, 37, '생활비')),
    jsonEncode(CashAsset('달러', 3000, 1065, '투자자산'))
  ];

  List<double> exchangeRate = [1, 38.5, 1070.4]; // todo: 현재 환율 웹스크래핑으로 가져오기


  @override
  void initState() {
    super.initState();
    date = '';
    monthlyGoal = ""; // todo: 저장된 값 가져오기
    textFieldController.addListener(() {
      monthlyGoal = textFieldController.text;
    });

    // json 리스트를 CashAsset 리스트로 변경
    for(String cashData in cashJsonList) {
      cashDataList.add(CashAsset.fromJson(jsonDecode(cashData)));
    }
    //todo: date를 선택했을 때 현금,투자 내역을 받아서 리스트로 변경
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
                getDropDownButton(date, dateDropdownList)
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
            Text('현금현황', textScaleFactor: 2),
            makeTable(CASH_REPORT),
            SizedBox(height: 50),
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
      ),
    );
  }

  DataTable makeTable(String type) {
    List<DataColumn> dataColumn = [];
    List<DataRow> dataRow = [];

    switch (type) {
      case CASH_REPORT :
        List<String> columns = ['통화','총액','증감','환율'];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(cashDataList.length, (index) =>
          DataRow(
            cells: [
              DataCell(Text(cashDataList[index].currency)),
              DataCell(Text(f.format(cashDataList[index].amount))),
              DataCell(Text(f.format(cashDataList[index].amount))), // todo: 환율 및 현금변동내역 반영할 것
              DataCell(Text(f.format(exchangeRate[index]))),
            ]
          )
        );
        break;

      case CASH_DETAIL :
        List<String> columns = ['통화','내용','금액', ''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        if(cashDetailList.isEmpty) {
          CashDetail cashDetail = CashDetail();
          dataRow = [
            DataRow(
              cells: [
                DataCell(getDropDownButton(cashDetail.currency, currencyDropdownList)),
                DataCell(TextField()),
                DataCell(TextField()),
                DataCell(IconButton(onPressed: (){}, icon: Icon(Icons.cancel_outlined, color: Colors.red)))
              ]
            )
          ];
        } else {
          dataRow = List<DataRow>.generate(cashDetailList.length, (index) =>
              DataRow(
                  cells: [
                    DataCell(getDropDownButton(cashDetailList[index].currency, currencyDropdownList)),
                    DataCell(Text(cashDetailList[index].title)),
                    DataCell(Text(f.format(cashDetailList[index].amount))),
                    DataCell(IconButton(onPressed: (){}, icon: Icon(Icons.cancel_outlined, color: Colors.red)))
                  ]
              )
          );
        }
        break;
    }

    return DataTable(
      headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
      columns: dataColumn,
      rows: dataRow,
    );
  }

  DropdownButton getDropDownButton(String value, List<String> list) {
    return DropdownButton(
        value: value,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 20,
        elevation: 10,
        onChanged: (dynamic newValue) {
          setState(() {
            value = newValue!;  //todo: value 값이 안 바뀜
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
