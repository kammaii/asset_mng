import 'package:asset_mng/circle_widget.dart';
import 'package:asset_mng/scraping_api.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:math';
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

  String thisMonth = '';
  bool isMonthChanged = true;
  bool isInitState = false;
  List<CircleWidget> circleWidgetList = [];
  late int index;
  late bool isFirstLineChart;

  late List<String> monthListWithEx;
  late List<double> totalAssetListWithEx;
  late List<double> goalAssetListWithEx;

  List<String> assetVariation = [];


  // 월리스트, 총액리스트, 목표리스트
  getInitList() async {
    await Database().getInitList();
    thisMonth = Database().monthList.last;
  }

  Future<bool> getData() async {
    if(isInitState) {
      await getInitList();
      isInitState = false;
    }
    if(isMonthChanged) {
      isMonthChanged = false;
      index = Database().monthList.indexOf(thisMonth) - 1;
      await Database().getSpecificMonthData(thisMonth);
      calcAssetVariation();
      initCircleWidget(index);
    }
    return true;
  }

  void calcAssetVariation() {
    assetVariation = [];
    List<double> asset = [];
    asset.add(Database().totalCashAssetList[index] - Database().totalCashAssetList[index-1]);
    asset.add(Database().totalInvestAssetList[index] - Database().totalInvestAssetList[index-1]);
    asset.add(Database().totalPensionAssetList[index] - Database().totalPensionAssetList[index-1]);
    for(double d in asset) {
      if(d >= 0) {
        assetVariation.add('+${f.format(d)}');
      } else {
        assetVariation.add('${f.format(d)}');
      }
    }
  }

  void initCircleWidget(int index) {
    circleWidgetList = [];
    circleWidgetList.add(CircleWidget(0, index));
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
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        Widget child;
        if(snapshot.hasData) {
          monthListWithEx = Database().exMonthList + Database().monthList.sublist(1);
          totalAssetListWithEx = Database().exTotalAssetList + Database().totalAssetList;
          goalAssetListWithEx = Database().exGoalAssetList + Database().goalAssetList;

          child = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(onPressed: (){
                ScrapingApi().getScraping();
              }, child: Text('Functions')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: getDropDownButton(thisMonth, Database().monthList, (newValue) {
                  thisMonth = newValue;
                  isMonthChanged = true;
                }),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: circleWidgetList.length,
                      itemBuilder: (context, index) {
                        return getCircleChart(circleWidgetList[index]);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 20),
                      child: Container(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('<전월대비>', textScaleFactor: 1.3),
                            SizedBox(height: 20),
                            Text('생활비: ${assetVariation[0]}'),
                            SizedBox(height: 10),
                            Text('투자: ${assetVariation[1]}'),
                            SizedBox(height: 10),
                            Text('연금: ${assetVariation[2]}')
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 80, bottom: 40),
                    child: getLineChart(),
                  )
              )
            ],
          );
        } else {
          child = Align(
            alignment: Alignment.center,
            child: Container(
              height: 100,
              width: 100,
              child: LoadingIndicator(
                colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple],
                indicatorType: Indicator.ballSpinFadeLoader,
              ),
            ),
          );
        }
        return child;
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

  FlTitlesData titlesData() {
    return FlTitlesData(
      bottomTitles: SideTitles(
        showTitles: true,
        getTextStyles: (_) => TextStyle(
          color: Colors.black,
          fontSize: 15
        ),
        getTitles: (value) {
          String month = monthListWithEx[value.toInt()];
          if(month.contains('.01')) {
            return '\''+month.substring(0,2);
          } else {
            return '';
          }
        }
      ),
      leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (_) => TextStyle(
              color: Colors.black,
              fontSize: 15
          ),
          getTitles: (value) {
            if(value == 0) {
              return '';
            } else {
              return '$value 억';
            }
          }
      ),
    );
  }

  LineTooltipItem getLineTooltipItem(bool isFirst, LineBarSpot spot) {
    String text1;
    String text2;
    Color color1;
    Color color2;
    int index = spot.spotIndex;
    double goal = (goalAssetListWithEx)[index];
    double asset = (totalAssetListWithEx)[index];
    double gap = asset - goal;
    String gapString;
    if(gap >= 0) {
      gapString = '+ ${f.format(gap)}';
    } else {
      gapString = f.format(gap);
    }
    if(isFirst) {
      text1 = '${(monthListWithEx)[(spot.x).toInt()]} \n';
      text2 = '목표: ${f.format(goal)}';
      color1 = Color(0xff000000);
      color2 = Color(0xffFF9994);
      isFirstLineChart = false;
    } else {
      text1 = '실적: ${f.format(asset)} \n';
      text2 = gapString;
      color1 = Color(0xffA30700);
      if(gap >= 0) {
        color2 = Colors.green;
      } else {
        color2 = Colors.red;
      }

    }
    return LineTooltipItem(
      text1,
      TextStyle(
        color: color1,
      ),
      children: [
        TextSpan(
          text: text2,
          style: TextStyle(
            color: color2,
          ),
        )
      ],
    );
  }

  LineTouchData lineTouchData() {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Color(0xffE1E0F3),
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          isFirstLineChart = true;
          return touchedSpots.map((spot) {
            return getLineTooltipItem(isFirstLineChart, spot);
          }).toList();
        }
      )
    );
  }

  LineChartBarData getAssetLine(bool isTotalAsset) {
    List<double> data;
    List<Color> colors;
    if(isTotalAsset) {
      data = totalAssetListWithEx;
      colors = [Color(0xffA30700), Color(0xffA30700)];
    } else {
      data = goalAssetListWithEx;
      colors = [Color(0xffFF9994), Color(0xffFF9994)];
    }
    return LineChartBarData(
        isCurved: true,
        colors: colors,
        spots: List.generate(data.length, (i) {
          double y = double.parse((data[i]/100000000).toStringAsFixed(2));
          return FlSpot(i.toDouble(), y);
        })
    );
  }

  LineChart getLineChart() {
    return LineChart(
        LineChartData(
          minX: 0,
          maxX: (monthListWithEx.length-1).toDouble(),
          minY: 0,
          maxY: (totalAssetListWithEx.reduce(max)/100000000).ceil().toDouble(),
          titlesData: titlesData(),
          lineTouchData: lineTouchData(),
          lineBarsData: [
            getAssetLine(true),
            getAssetLine(false),
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
