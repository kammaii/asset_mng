import 'package:asset_mng/circle_widget.dart';
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
  int touchedIndex = -1;
  String touchedChartTitle = '';
  List<Color> chartColors = [
    Color(0xff6E8DFA),Color(0xffBBFA56),Color(0xffFA6248),Color(0xffFACB48),Color(0xff61FAB7),Color(0xffFA7F9E),Color(0xff5CDDFA),Color(0xffFAE443),Color(0xff50FA68),Color(0xff8269FA)
  ];
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  String thisMonth = '';
  bool isMonthChanged = true;
  bool isInitState = false;
  List<CircleWidget> circleWidgetList = [];
  late int index;

  // 월리스트, 총액리스트, 목표리스트
  getInitList() async {
    await Database().getInitList();
    thisMonth = Database().monthList.last;
  }

  Future<void> getData() async {
    if(isInitState) {
      await getInitList();
      isInitState = false;
    }
    if(isMonthChanged) {
      await Database().getSpecificMonthData(thisMonth);
      isMonthChanged = false;
    }
    initCircleWidget();
  }

  void initCircleWidget() {
    index = Database().monthList.indexOf(thisMonth) - 1;
    if(index > 0 && circleWidgetList.length == 0) {
      circleWidgetList = [];
      circleWidgetList.add(CircleWidget(0, index));
    }
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: getDropDownButton(thisMonth, Database().monthList, (newValue) {
                thisMonth = newValue;
                isMonthChanged = true;
                getData();
              }),
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: circleWidgetList.length,
                    itemBuilder: (context, index) {
                      return getCircleChart(circleWidgetList[index]);
                    },
                  )
                ],
              ),
            ),
            SizedBox(height: 30.0),
            Expanded(
                child: getLineChart()
            )
          ],
        );
      },
    );
  }

  Widget getCircleChart(CircleWidget circleWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('<${circleWidget.title}>', textScaleFactor: 1.3),
          GestureDetector(
            onTap: () {
              String title = circleWidget.title;
              String item = circleWidget.itemList[touchedIndex];

              switch (title) {
                case '총자산':
                  setState(() {
                    if(circleWidgetList.length > 1) {
                      circleWidgetList.removeRange(1, circleWidgetList.length);
                    }
                    if(item == '생활비') {
                      circleWidgetList.add(CircleWidget(1, index));
                    } else if (item == '투자') {
                      circleWidgetList.add(CircleWidget(2, index));
                    } else if (item == '연금') {
                      circleWidgetList.add(CircleWidget(3, index));
                    }
                  });
                  break;

                case '투자자산' :
                  if(circleWidgetList.length == 3) {
                    circleWidgetList.removeLast();
                  }
                  circleWidgetList.add(CircleWidget(2, index, item));
                  break;

                case '연금자산' :
                  if(circleWidgetList.length == 3) {
                    circleWidgetList.removeLast();
                  }
                  circleWidgetList.add(CircleWidget(3, index, item));
                  break;
              }
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
                          touchedChartTitle = circleWidget.title;
                        } else {
                          //f(-1);
                        }
                      });
                    }),
                    startDegreeOffset: -90,
                    centerSpaceRadius: 0,
                    sections: getSections(circleWidget)
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 250,
                height: 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: circleWidget.itemList.length,
                  itemBuilder: (context, index) {
                    return getIndicators(circleWidget)[index];
                  },
                ),
              )
            ]
          )
        ],
      ),
    );
  }

  Color getChartColor(int index) {
    Color color = chartColors[index % chartColors.length];
    return color;
  }

  Color getTextColor(String title, int index, bool isChart) {
    Color color;
    bool isSelected = touchedChartTitle == title && touchedIndex == index ? true : false;
    if(isChart) {
      isSelected ? color = Colors.black : color = Colors.white;
    } else {
      isSelected ? color=Colors.red : color=Colors.black;
    }
    return color;
  }

  List<Padding> getIndicators(CircleWidget circleWidget) {
    double circleSize = 15;
    List<Padding> indicators = List.generate(circleWidget.itemList.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getChartColor(i)
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: Text(circleWidget.itemList[i], style: TextStyle(color: getTextColor(circleWidget.title,i,false)), textAlign: TextAlign.start)),
                  SizedBox(width: 10),
                  Text('(${f.format(circleWidget.priceList[i].ceilToDouble())} 원)', style: TextStyle(color: getTextColor(circleWidget.title,i,false)))
                ],
              ),
            )
          ],
        ),
      );
    });
    List<Padding> reversed = List.from(indicators.reversed);
    return reversed;
  }

  List<PieChartSectionData> getSections(CircleWidget circleWidget) {
    return List.generate(circleWidget.percentList.length, (i) {
      final isTouched = i == touchedIndex && circleWidget.title == touchedChartTitle ? true : false;
      final fontSize = isTouched ? 18.0 : 15.0;
      final radius = isTouched ? circleChartRadius+10 : circleChartRadius;

      return PieChartSectionData(
        color: getChartColor(i),
        value: circleWidget.percentList[i],
        title: '${circleWidget.percentList[i].toString()}%',
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize, fontWeight: FontWeight.bold, color: getTextColor(circleWidget.title,i,true)),
      );
    });
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
