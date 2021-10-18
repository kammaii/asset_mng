import 'package:asset_mng/cash_asset.dart';
import 'package:asset_mng/invest_asset.dart';
import 'package:asset_mng/pension_asset.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'database.dart';

class MainAssets extends StatefulWidget {
  const MainAssets({Key? key}) : super(key: key);

  @override
  _MainAssetsState createState() => _MainAssetsState();
}

class _MainAssetsState extends State<MainAssets> {
  var f = NumberFormat('###,###,###,###.##');
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
  bool isMonthChanged = false;
  bool isInitState = false;

  // 월리스트, 총액리스트, 목표리스트
  getInitList() async {
    await Database().getInitList();
    thisMonth = Database().monthList.last;
  }

  getAssetData() async {
    await Database().getSpecificMonthData(thisMonth);
  }

  Future<void> getData() async {
    if(isInitState) {
      await getInitList();
      isInitState = false;
    }
    await getAssetData();
  }

  @override
  void initState() {
    super.initState();
    isInitState = true;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: getData(),
      builder: (ctx, snapShot) {
        List<String> assetChartTitle = [];
        List<String> assetChartPrice = [];
        List<double> assetChartPercent = [];
        int index = Database().monthList.indexOf(thisMonth)-1;
        if(index >= 0) {
          double totalAsset = Database().totalAssetList[index];
          double totalCash = Database().totalCashAssetList[index];
          double totalInvest = Database().totalInvestAssetList[index];
          double totalPension = Database().totalPensionAssetList[index];
          assetChartTitle.add('생활비');
          assetChartTitle.add('투자');
          assetChartTitle.add('연금');
          assetChartPrice.add('(${f.format(Database().totalCashAssetList[index])} 원)');
          assetChartPrice.add('(${f.format(Database().totalInvestAssetList[index])} 원)');
          assetChartPrice.add('(${f.format(Database().totalPensionAssetList[index])} 원)');
          assetChartPercent.add(double.parse((totalCash/totalAsset*100).toStringAsFixed(1)));
          assetChartPercent.add(double.parse((totalInvest/totalAsset*100).toStringAsFixed(1)));
          assetChartPercent.add(double.parse((totalPension/totalAsset*100).toStringAsFixed(1)));
          print(totalCash/totalAsset*100);
          print(totalInvest/totalAsset*100);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: getDropDownButton(thisMonth, Database().monthList, (newValue) {
                thisMonth = newValue;
                getData();
              }),
            ),
            Row(
              children: [
                getCircleChart(assetChartTitle, assetChartPrice, assetChartPercent),
              ],
            ),
            SizedBox(height: 10.0),
            Expanded(
                child: getLineChart()
            )
          ],
        );
      },
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

  Widget getCircleChart(List<String> titleList, List<String> priceList, List<double> percentList) {
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
                  sections: getSections(percentList)
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: getIndicators(titleList, priceList),
        )
      ],
    );
  }

  List<Row> getIndicators(List<String> titleList, List<String> titlePrice) {
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
          Container(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titleList[i], style: TextStyle(color: textColor)),
                Text(titlePrice[i], style: TextStyle(color: textColor))
              ],
            ),
          )
        ],
      );
    });
  }

  List<PieChartSectionData> getSections(List<double> valueList) {
    return List.generate(valueList.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 15.0;
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
