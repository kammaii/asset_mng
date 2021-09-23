import 'package:asset_mng/cash_asset.dart';
import 'package:asset_mng/invest_asset.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'cash_detail.dart';
import 'cash_gap.dart';
import 'database.dart';

class CashFlow extends StatefulWidget {
  const CashFlow({Key? key}) : super(key: key);

  @override
  _CashFlowState createState() => _CashFlowState();
}

class _CashFlowState extends State<CashFlow> {
  static const String CASH_ASSET = 'cashAsset';
  static const String INVEST_ASSET = 'investAsset';
  static const String LAST_CASH = 'lastCash';
  static const String CASH_DETAIL = 'cashDetail';

  String thisMonth = '';
  String newMonth = '';
  List<String> assetTypeDropdownList = ['투자자산', '연금자산', '생활비']; // todo: 입력받을 수 있는 기능 만들기
  List<String> currencyDropdownList = ['원', '달러', '바트']; // todo: 입력받을 수 있는 기능 만들기

  var f = NumberFormat('###,###,###,###.##');
  late double assetGoal;
  double monthGoal = 0;
  static const double cardPadding = 30.0;
  static const double cardElevation = 5.0;

  late List<CashAsset> cashAssetList;
  late List<CashDetail> cashAssetDetailList;
  late List<InvestAsset> investAssetList;
  late List<CashAsset> lastCashAssetList;
  late List<CashGap> cashGapList;

  bool isInputMode = true;
  bool isModeChanged = true;

  double totalCash = 0;
  double totalInvest = 0;
  double totalAsset = 0;

  void initData() {
    assetGoal = 0;
    cashAssetList = [];
    cashAssetDetailList = [];
    lastCashAssetList = [];
    investAssetList = [];
  }

  void setInputModeData() async {
    initData();
    await Database().getLastMonthData();
    monthGoal = Database().monthGoal;
    assetGoal = Database().assetGoal + (monthGoal * 10000);
    for(CashAsset cashAsset in Database().cashList) {
      cashAssetList.add(cashAsset);
      CashAsset asset = CashAsset.clone(cashAsset);
      lastCashAssetList.add(asset);
    }
    for(InvestAsset investAsset in Database().investList) {
      investAssetList.add(investAsset);
    }
    setState(() {});
  }

  void setReadModeData() async {
    initData();
    int thisMonthIndex = Database().monthList.indexOf(thisMonth);
    await Database().getSpecificMonthData(thisMonth);
    assetGoal = Database().assetGoal;
    for(CashAsset cashAsset in Database().cashList) {
      cashAssetList.add(cashAsset);
    }
    for(CashDetail cashAssetDetail in Database().cashDetailList) {
      cashAssetDetailList.add(cashAssetDetail);
    }
    for(InvestAsset investAsset in Database().investList) {
      investAssetList.add(investAsset);
    }
    print(Database().monthList.length);
    if(Database().monthList.length > 2) {
      await Database().getCashAsset(Database().monthList[thisMonthIndex - 1]);
    }
    for(CashAsset cashAsset in Database().cashList) {
      lastCashAssetList.add(cashAsset);
    }
    setState(() {});
  }

  // 현금, 투자 자산 총액 구하기
  void getTotalAsset() {
    totalCash = 0;
    totalInvest = 0;
    Map<String, double> exchangeRate = Map(); //todo: 환율정보를 DB에서 가져오는 것으로 수정할 것!!!
    for(CashAsset cashAsset in cashAssetList) {
      totalCash += cashAsset.amount * cashAsset.exchangeRate;
      exchangeRate[cashAsset.currency] = cashAsset.exchangeRate;
    }
    for(InvestAsset investAsset in investAssetList) {
      double rate = exchangeRate[investAsset.currency]!.toDouble();
      totalInvest += (investAsset.getGrossValue() * rate);
    }
    totalCash = totalCash.ceilToDouble();
    totalInvest = totalInvest.ceilToDouble();
    totalAsset = totalCash + totalInvest;
  }

  void checkGap() {
    cashGapList = [];
    for(CashAsset cashAsset in cashAssetList) {
      double gap = cashAsset.amount;
      for (CashAsset lastCashAsset in lastCashAssetList) {
        if(cashAsset.assetType == lastCashAsset.assetType && cashAsset.currency == lastCashAsset.currency) {
          gap -= lastCashAsset.amount;
        }
      }
      for(CashDetail cashDetail in cashAssetDetailList) {
        if(cashAsset.assetType == cashDetail.assetType && cashAsset.currency == cashDetail.currency) {
          gap -= cashDetail.amount;
        }
      }
      cashGapList.add(CashGap(cashAsset.assetType, cashAsset.currency, gap));
    }
    for(CashAsset lastCashAsset in lastCashAssetList) {
      bool hasExhaustedCash = true;
      for(CashAsset cashAsset in cashAssetList) {
        if(lastCashAsset.assetType == cashAsset.assetType && lastCashAsset.currency == cashAsset.currency) {
          hasExhaustedCash = false;
          break;
        }
      }
      if(hasExhaustedCash) {
        double gap = lastCashAsset.amount;
        for(CashDetail cashDetail in cashAssetDetailList) {
          if(lastCashAsset.assetType == cashDetail.assetType && lastCashAsset.currency == cashDetail.currency) {
            gap += cashDetail.amount;
          }
        }
        cashGapList.add(CashGap(lastCashAsset.assetType, lastCashAsset.currency, gap));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(isModeChanged) {
      isInputMode ? setInputModeData() : setReadModeData();
      isModeChanged = false;
    }
    getTotalAsset();
    checkGap();


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
                      setState(() {
                        thisMonth = '';
                        newMonth = '';
                        isInputMode = true;
                        isModeChanged = true;
                      });
                    },
                    child: Text('입력하기')),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text('년/월: '),
                SizedBox(width: 20),
                getDropDownButton(thisMonth, Database().monthList, (newValue) {
                  thisMonth = newValue;
                  isInputMode = false;
                  isModeChanged = true;
                }),
                SizedBox(width: 20),
                Visibility(
                  visible: isInputMode,
                  child: getTextField(newMonth, (newValue) => newMonth = newValue),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text('목표:'),
                SizedBox(width: 20),
                getTextField(assetGoal, (newValue) => assetGoal = double.parse(newValue.replaceAll(',', ''))),
                SizedBox(width: 50),
                Text('원  (월'),
                SizedBox(width: 10),
                getTextField(monthGoal, (newValue) {
                  double newGoal = double.parse(newValue.replaceAll(',', ''));
                  monthGoal = newGoal;
                }),
                SizedBox(width: 5),
                Text('만원)'),
              ],
            ),
            SizedBox(height: 20),
            Text('실적:    ${f.format(totalAsset)}   원', textScaleFactor: 1.2),
            SizedBox(height: 50),
            Card(
              elevation: cardElevation,
              child: Padding(
                padding: const EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('현금현황', textScaleFactor: 2),
                        SizedBox(width: 20),
                        Text('(총  ' + f.format(totalCash) + '  원)', textScaleFactor: 1.5)
                      ],
                    ),
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
                              cashAssetList.add(CashAsset(cashAssetList.length));
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: cardElevation,
                  child: Padding(
                    padding: const EdgeInsets.all(cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('전월현금', textScaleFactor: 2),
                        SizedBox(height: 20),
                        makeTable(LAST_CASH),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: cardElevation,
                  child: Padding(
                    padding: const EdgeInsets.all(cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('증감내역', textScaleFactor: 2),
                        SizedBox(height: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            makeTable(CASH_DETAIL),
                            SizedBox(height: 20),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                              onPressed: () {
                                setState(() {
                                  cashAssetDetailList.add(CashDetail(cashAssetDetailList.length));
                                });
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 50),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('오차', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 10),
                        cashGapList.length > 0 ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: cashGapList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              children: [
                                Text(cashGapList[index].assetType),
                                SizedBox(width: 10),
                                Text(cashGapList[index].currency),
                                SizedBox(width: 10),
                                Text(f.format(cashGapList[index].gap))
                              ],
                            );
                          },
                        ) : Text(''),
                      ]
                    ),
                  ),
                )
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
                    Row(
                      children: [
                        Text('투자현황', textScaleFactor: 2),
                        SizedBox(width: 20),
                        Text('(총  ' + f.format(totalInvest) + '  원)', textScaleFactor: 1.5)
                      ],
                    ),
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
                              investAssetList.add(InvestAsset(investAssetList.length));
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  getDialog('저장하기', '저장할까요?', Colors.blue, (){
                    String date;
                    isInputMode? date = newMonth : date = thisMonth;
                    if(date.isNotEmpty) {
                      Database().saveAsset(context, date, assetGoal, monthGoal, cashAssetList, cashAssetDetailList, investAssetList);
                    } else {
                      showAlert('년/월을 입력하세요.');
                    }
                  }),
                  SizedBox(width: 20),
                  getDialog('삭제하기', '삭제할까요?', Colors.red, (){print('삭제');})
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAlert(String title) {
    AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.BOTTOMSLIDE,
        btnCancelText: 'Ok',
        title: title,
        btnCancelOnPress: () {},
    )..show();
  }


  ElevatedButton getDialog(String btnText, String title, Color color, Function f) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(primary: color),
        onPressed: () {
          AwesomeDialog(
              width: 500,
              context: context,
              dialogType: DialogType.INFO,
              animType: AnimType.BOTTOMSLIDE,
              title: title,
              btnOkText: '네',
              btnCancelText: '아니요',
              btnCancelOnPress: () {},
              btnOkOnPress: () {
                f();
              }
          )..show();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(btnText),
        )
    );
  }

  DataTable makeTable(String type) {
    List<DataColumn> dataColumn = [];
    List<DataRow> dataRow = [];

    switch (type) {
      case CASH_ASSET :
        List<String> columns = ['자산타입','통화','금액','증가액','환율','원화환산','',''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(cashAssetList.length, (index) {
          double variation = cashAssetList[index].amount;
          for(CashAsset lastCashAsset in lastCashAssetList) {
            if(lastCashAsset.assetType == cashAssetList[index].assetType && lastCashAsset.currency == cashAssetList[index].currency) {
              variation = cashAssetList[index].amount - lastCashAsset.amount;
            }
          }
          return DataRow(
              cells: [
                DataCell(getDropDownButton(cashAssetList[index].assetType, assetTypeDropdownList, (newValue) => cashAssetList[index].assetType = newValue)),
                DataCell(getDropDownButton(cashAssetList[index].currency, currencyDropdownList, (newValue) => cashAssetList[index].currency = newValue)),
                DataCell(getTextField(cashAssetList[index].amount, (newValue) => cashAssetList[index].amount = double.parse(newValue.replaceAll(',', '')))),
                DataCell(Text(f.format(variation))),
                DataCell(getTextField(cashAssetList[index].exchangeRate, (newValue) => cashAssetList[index].exchangeRate = double.parse(newValue.replaceAll(',', '')))),
                DataCell(Text(f.format(cashAssetList[index].amount * cashAssetList[index].exchangeRate))),
                DataCell(IconButton(
                    onPressed: () {
                      setState(() {
                        cashAssetList.removeAt(index);
                        for(int i=index; i<cashAssetList.length; i++) {
                          cashAssetList[i].no--;
                        }
                      });
                    },
                    icon: Icon(Icons.cancel_outlined, color: Colors.red))
                ),
                DataCell(getIndexEdit(index, (isUpside) {
                  if(isUpside && index != 0) {
                    setState(() {
                      cashAssetList[index].no--;
                      cashAssetList[index - 1].no++;
                      CashAsset asset = cashAssetList[index];
                      cashAssetList.removeAt(index);
                      cashAssetList.insert(index-1, asset);
                    });

                  } else if(!isUpside && index != cashAssetList.length-1) {
                    setState(() {
                      cashAssetList[index].no++;
                      cashAssetList[index + 1].no--;
                      CashAsset asset = cashAssetList[index];
                      cashAssetList.removeAt(index);
                      cashAssetList.insert(index+1, asset);
                    });
                  }
                }))
              ]
          );
        });
        break;

      case LAST_CASH :
        List<String> columns = ['자산타입','통화','금액'];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(lastCashAssetList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(Text(lastCashAssetList[index].assetType)),
                  DataCell(Text(lastCashAssetList[index].currency)),
                  DataCell(Text(f.format(lastCashAssetList[index].amount))),
                ]
            )
        );
        break;

      case CASH_DETAIL :
        List<String> columns = ['자산타입','통화','금액','내용','',''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(cashAssetDetailList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getDropDownButton(cashAssetDetailList[index].assetType, assetTypeDropdownList, (newValue) => cashAssetDetailList[index].assetType = newValue)),
                  DataCell(getDropDownButton(cashAssetDetailList[index].currency, currencyDropdownList, (newValue) => cashAssetDetailList[index].currency = newValue)),
                  DataCell(getTextField(cashAssetDetailList[index].amount, (newValue) => cashAssetDetailList[index].amount = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(getTextField(cashAssetDetailList[index].note, (newValue) => cashAssetDetailList[index].note = newValue)),
                  DataCell(IconButton(
                      onPressed: () {
                        setState(() {
                          cashAssetDetailList.removeAt(index);
                          for(int i=index; i<cashAssetDetailList.length; i++) {
                            cashAssetDetailList[i].no--;
                          }
                        });
                      },
                      icon: Icon(Icons.cancel_outlined, color: Colors.red))
                  ),
                  DataCell(getIndexEdit(index, (isUpside) {
                    if(isUpside && index != 0) {
                      setState(() {
                        cashAssetDetailList[index].no--;
                        cashAssetDetailList[index - 1].no++;
                        CashDetail detail = cashAssetDetailList[index];
                        cashAssetDetailList.removeAt(index);
                        cashAssetDetailList.insert(index-1, detail);
                      });

                    } else if(!isUpside && index != cashAssetDetailList.length-1) {
                      setState(() {
                        cashAssetDetailList[index].no++;
                        cashAssetDetailList[index + 1].no--;
                        CashDetail detail = cashAssetDetailList[index];
                        cashAssetDetailList.removeAt(index);
                        cashAssetDetailList.insert(index+1, detail);
                      });
                    }
                  }))
                ]
            )
        );
        break;

      case INVEST_ASSET :
        List<String> columns = ['자산타입','통화','종목','매수가','현재가', '수량', '매입총액', '평가액' ,'수익', '수익률', '태그','',''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(investAssetList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getDropDownButton(investAssetList[index].assetType, assetTypeDropdownList, (newValue) => investAssetList[index].assetType = newValue)),
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
                          investAssetList.removeAt(index);
                          for(int i=index; i<investAssetList.length; i++) {
                            investAssetList[i].no--;
                          }
                        });
                      },
                      icon: Icon(Icons.cancel_outlined, color: Colors.red))
                  ),
                  DataCell(getIndexEdit(index, (isUpside) {
                    if(isUpside && index != 0) {
                      setState(() {
                        investAssetList[index].no--;
                        investAssetList[index - 1].no++;
                        InvestAsset asset = investAssetList[index];
                        investAssetList.removeAt(index);
                        investAssetList.insert(index-1, asset);
                      });

                    } else if(!isUpside && index != investAssetList.length-1) {
                      setState(() {
                        investAssetList[index].no++;
                        investAssetList[index + 1].no--;
                        InvestAsset asset = investAssetList[index];
                        investAssetList.removeAt(index);
                        investAssetList.insert(index+1, asset);
                      });
                    }
                  }))
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

  Row getIndexEdit(int index, Function(bool) f) {
    return Row(
      children: [
        Expanded(
          child: IconButton(
            icon: Icon(Icons.arrow_drop_up_rounded),
            onPressed: () {
              f(true);
            },
          ),
        ),
        Expanded(
          child: IconButton(
            icon: Icon(Icons.arrow_drop_down_rounded),
            onPressed: () {
              f(false);
            },
          ),
        ),
      ],
    );
  }

  Container getTextField(dynamic data, Function(String) function) {
    TextEditingController textFieldController = TextEditingController();
    textFieldController.addListener(() {
      function(textFieldController.text);
    });
    List<TextInputFormatter> inputFormatter = [];
    if(data is String) {
      textFieldController.text = data;
    } else {
      textFieldController.text = f.format(data);
      //inputFormatter.add(FilteringTextInputFormatter.digitsOnly); //todo: 마이너스 입력 안됨!!
    }
    return Container(
      height: 30,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 50),
        child: IntrinsicWidth(
          child: Focus(
            onFocusChange: (hasFocus) {
              if(!hasFocus) {
                setState(() {});
              }
            },
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(15,0,15,15)
              ),
              textAlign: TextAlign.center,
              controller: textFieldController,
              inputFormatters: inputFormatter,
            ),
          ),
        ),
      ),
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
