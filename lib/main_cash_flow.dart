import 'dart:convert';
import 'package:asset_mng/cash_asset.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashFlow extends StatefulWidget {
  const CashFlow({Key? key}) : super(key: key);

  @override
  _CashFlowState createState() => _CashFlowState();
}

class _CashFlowState extends State<CashFlow> {
  String dropdownValue = '21년 7월';
  List<String> dropdownItems = ['1', '2', '3', '4'];
  double assetGoal = 100000000;
  var f = NumberFormat('###,###,###,###.##');
  final textFieldController = TextEditingController();
  late String monthlyGoal;

  List<Map<String, dynamic>> cashDataList = [];

  static const String CASH_REPORT = 'cashReport';

  List<String> cashJsonList = [ // todo: 샘플 현금 현황 (실재 DB에서 받는 데이터 형태)
    jsonEncode(CashAsset('원화', 1000000, 1, '생활비')),
    jsonEncode(CashAsset('바트', 5555, 37, '생활비')),
    jsonEncode(CashAsset('달러', 3000, 1065, '투자자산'))
  ];

  List<double> exchangeRate = [1, 38.5, 1070.4]; // todo: 현재 환율 웹스크래핑으로 가져오기


  @override
  void initState() {
    super.initState();
    monthlyGoal = ""; // todo: 저장된 값 가져오기
    textFieldController.addListener(() {
      monthlyGoal = textFieldController.text;
    });

    // json 리스트를 Map 리스트로 변경
    for(String cashData in cashJsonList) {
      cashDataList.add(jsonDecode(cashData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              DropdownButton(
                value: '1',
                icon: Icon(Icons.arrow_downward),
                iconSize: 20,
                elevation: 10,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList()
              )
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
                      bottom: 15,  // HERE THE IMPORTANT PART
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
          makeTable(CASH_REPORT)
        ],
      ),
    );
  }

  DataTable makeTable(String type) {
    List<DataColumn> dataColumn = [];
    List<DataRow> dataRow = [];

    switch (type) {
      case CASH_REPORT :
        List<String> columns = ['','총액','증감','환율'];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => getColumn(columns[index]));
        dataRow = List<DataRow>.generate(cashDataList.length, (index) =>
          DataRow(
            cells: [
              DataCell(Text(cashDataList[index][CashAsset.CURRENCY])),
              DataCell(Text(cashDataList[index][CashAsset.AMOUNT].toString())),
              DataCell(Text(cashDataList[index][CashAsset.AMOUNT].toString())), // todo: 환율 및 현금변동내역 반영할 것
              DataCell(Text(exchangeRate[index].toString())),
            ]
          )
        );
        break;
    }

    return DataTable(
      columns: dataColumn,
      rows: dataRow,
    );
  }

  DataColumn getColumn(String label) {
    return DataColumn(
      label: Text(label, style: TextStyle(fontWeight: FontWeight.bold))
    );
  }
}
