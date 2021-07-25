import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MainAssets extends StatefulWidget {
  const MainAssets({Key? key}) : super(key: key);

  @override
  _MainAssetsState createState() => _MainAssetsState();
}

class _MainAssetsState extends State<MainAssets> {
  double circleChartRadius = 80.0;
  int touchedIndex = -1;
  List<Color> chartColors = [Color(0xff6E8DFA),Color(0xffBBFA56),Color(0xffFA6248),Color(0xffFACB48),Color(0xff61FAB7),Color(0xffFA7F9E),Color(0xff5CDDFA),Color(0xffFAE443),Color(0xff50FA68),Color(0xff8269FA)];
  List<String> testTitleList = ['삼성전자','NAVER','이노와이어리스','한국항공우주'];
  List<double> testValueList = [40, 30, 15, 15];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            getCircleChart(testTitleList, testValueList),
          ],
        ),
      ],
    );
  }

  Card getCircleChart(List<String> titleList, List<double> valueList) {
    return Card(
      margin: EdgeInsets.all(10.0),
      color: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                          touchedIndex = -1;
                        }
                      });
                    }),
                    startDegreeOffset: 180,
                    centerSpaceRadius: 0,
                    sections: getSections(valueList)
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
        ),
      ),
    );
  }

  List<Row> getIndicators(List<String> titleList) {
    double circleSize = 15;
    return List.generate(titleList.length, (i) {
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
          Text(titleList[i])
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
}
