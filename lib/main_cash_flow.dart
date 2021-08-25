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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {

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
              Text('목표: ${f.format(assetGoal)}')
            ],
          )
        ],
      ),
    );
  }
}
