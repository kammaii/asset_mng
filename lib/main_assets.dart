import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'database.dart';

class MainAssets extends StatefulWidget {
  const MainAssets({Key? key}) : super(key: key);

  @override
  _MainAssetsState createState() => _MainAssetsState();
}

class _MainAssetsState extends State<MainAssets> {
  double circleChartRadius = 80.0;
  late int touchedIndex = -1;
  List<Color> chartColors = [Color(0xff6E8DFA),Color(0xffBBFA56),Color(0xffFA6248),Color(0xffFACB48),Color(0xff61FAB7),Color(0xffFA7F9E),Color(0xff5CDDFA),Color(0xffFAE443),Color(0xff50FA68),Color(0xff8269FA)];
  List<String> testTitleList = ['삼성전자','NAVER','이노와이어리스','한국항공우주'];
  List<double> testValueList = [40, 30, 15, 15];
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  String thisMonth = '';
  bool isMonthChanged = true;

  void getMonthList() async {
    await Database().getMonthList();
    thisMonth = Database().monthList.last;
  }

  void getTotalAssetValues() async {
    //todo: 모든 달의 총액을가져옴
  }

  void getAssetData() async {
    await Database().getSpecificMonthData(thisMonth);
  }


  @override
  void initState() {
    super.initState();
    getMonthList();
    getTotalAssetValues();
  }

  @override
  Widget build(BuildContext context) {
    if(isMonthChanged) {
      getAssetData();
      isMonthChanged = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: getDropDownButton(thisMonth, Database().monthList, (newValue) {
            thisMonth = newValue;
            isMonthChanged = true;
          }),
        ),
        Row(
          children: [
            getCircleChart(testTitleList, testValueList),
          ],
        ),
        SizedBox(height: 10.0),
        Expanded(
          child: getLineChart()
        )
      ],
    );
  }

  LineChart getLineChart() {
    return LineChart(
        LineChartData(
            minX: 0,
            maxX: 11,
            minY: 0,
            maxY: 15,
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 3),
                  FlSpot(2, 5),
                  FlSpot(4, 9),
                  FlSpot(6, 10),
                  FlSpot(8, 5),
                  FlSpot(10, 7)
                ],
                isCurved: true,
                colors: gradientColors
              ),
              LineChartBarData(
                spots: [
                  FlSpot(0, 4),
                  FlSpot(2, 2),
                  FlSpot(4, 12),
                  FlSpot(6, 14),
                  FlSpot(8, 8),
                  FlSpot(10, 6)
                ],
                isCurved: true,
              )
            ]
        )
    );
  }

  Widget getCircleChart(List<String> titleList, List<double> valueList) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            print(touchedIndex);
          },
          child: Container(
            width: circleChartRadius*2.5,
            height: circleChartRadius*2.5,
            child: PieChart(
              PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                    setState(() {
                      final desiredTouch = pieTouchResponse.touchInput is! PointerExitEvent &&
                          pieTouchResponse.touchInput is! PointerUpEvent;
                      if (desiredTouch && pieTouchResponse.touchedSection != null) {
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      } else {
                        //f(-1);
                      }
                    });
                  }),
                  startDegreeOffset: 180,
                  centerSpaceRadius: 0,
                  sections: getSections(valueList)
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: getIndicators(titleList),
        )
      ],
    );
  }

  List<Row> getIndicators(List<String> titleList) {
    double circleSize = 15;
    return List.generate(titleList.length, (i) {
      Color textColor;
      touchedIndex == i ? textColor = Colors.red : textColor = Colors.black;

      return Row(
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: chartColors[i]
            ),
          ),
          SizedBox(width: 5),
          Text(titleList[i], style: TextStyle(color: textColor),
          )
        ],
      );
    });
  }

  List<PieChartSectionData> getSections(List<double> valueList) {
    return List.generate(valueList.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? circleChartRadius+10 : circleChartRadius;

      return PieChartSectionData(
        color: chartColors[i],
        value: valueList[i],
        title: '${valueList[i].toString()}%',
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
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
