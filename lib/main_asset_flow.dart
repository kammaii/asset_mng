import 'package:asset_mng/cash_asset.dart';
import 'package:asset_mng/invest_asset.dart';
import 'package:asset_mng/pension_asset.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'cash_detail.dart';
import 'cash_gap.dart';
import 'database.dart';
import 'package:loading_indicator/loading_indicator.dart';

class AssetFlow extends StatefulWidget {
  const AssetFlow({Key? key}) : super(key: key);

  @override
  _AssetFlowState createState() => _AssetFlowState();
}

class _AssetFlowState extends State<AssetFlow> {
  static const String CASH_ASSET = 'cashAsset';
  static const String INVEST_ASSET = 'investAsset';
  static const String PENSION_ASSET = 'pensionAsset';
  static const String LAST_CASH = 'lastCash';
  static const String CASH_DETAIL = 'cashDetail';

  String thisMonth = '';
  String newMonth = '';

  var f = NumberFormat('###,###,###,###.##');
  late double assetGoal;
  double monthGoal = 0;
  static const double cardPadding = 30.0;
  static const double cardElevation = 5.0;

  late List<CashAsset> cashAssetList;
  late List<CashDetail> cashAssetDetailList;
  late List<InvestAsset> investAssetList;
  late List<PensionAsset> pensionAssetList;
  late List<CashAsset> lastCashAssetList;
  late List<CashGap> cashGapList;

  bool isInputMode = true;
  bool isModeChanged = true;

  double totalCash = 0;
  double totalInvest = 0;
  double totalPension = 0;
  double totalAsset = 0;

  bool loading = true;
  bool isChecked = false;
  double investTax = 0;

  Future<bool> setData() async {
    if(isModeChanged) {
      if(isInputMode) {
        await setInputModeData();
      } else {
        await setReadModeData();
      }
      isModeChanged = false;
    }
    checkInvestTax();
    getTotalAsset();
    checkGap();
    return true;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: setData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        Widget child;
        if(snapshot.hasData) {
          child = mainPage();
        } else {
          child = loadingPage();
        }
        return child;
      }
    );
  }


  void initData() {
    assetGoal = 0;
    cashAssetList = [];
    cashAssetDetailList = [];
    lastCashAssetList = [];
    investAssetList = [];
    pensionAssetList = [];
  }

  Future<bool> setInputModeData() async {
    loading = true;
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
    for(PensionAsset pensionAsset in Database().pensionList) {
      pensionAssetList.add(pensionAsset);
    }
    return true;
  }

  Future<bool> setReadModeData() async {
    loading = true;
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
    for(PensionAsset pensionAsset in Database().pensionList) {
      pensionAssetList.add(pensionAsset);
    }
    if(Database().monthList[thisMonthIndex - 1] != '') {
      await Database().getCashAsset(Database().monthList[thisMonthIndex - 1]);
    }
    for(CashAsset cashAsset in Database().cashList) {
      lastCashAssetList.add(cashAsset);
    }
    return true;
  }

  // ??????, ?????? ?????? ?????? ?????????
  void getTotalAsset() {
    totalCash = 0;
    totalInvest = 0;
    totalPension = 0;
    for(CashAsset cashAsset in cashAssetList) {
      totalCash += cashAsset.amount * cashAsset.exchangeRate;
    }
    for(InvestAsset investAsset in investAssetList) {
      double rate = Database().exchangeRate[investAsset.currency]!.toDouble();
      totalInvest += (investAsset.getGrossValue() * rate);
    }
    totalInvest -= investTax;
    for(PensionAsset pensionAsset in pensionAssetList) {
      totalPension += pensionAsset.currentPrice;
    }

    totalCash = totalCash.ceilToDouble();
    totalInvest = totalInvest.ceilToDouble();
    totalPension = totalPension.ceilToDouble();
    print('1 $totalInvest');
    if(isChecked) {
      totalAsset = totalCash + totalInvest + totalPension;
    } else {
      totalAsset = totalCash + totalInvest;
    }
  }

  void checkGap() {
    cashGapList = [];
    for(CashAsset cashAsset in cashAssetList) {
      double gap = cashAsset.amount;
      for (CashAsset lastCashAsset in lastCashAssetList) {
        if(cashAsset.currency == lastCashAsset.currency) {
          gap -= lastCashAsset.amount;
        }
      }
      for(CashDetail cashDetail in cashAssetDetailList) {
        if(cashAsset.currency == cashDetail.currency) {
          gap -= cashDetail.amount;
        }
      }
      cashGapList.add(CashGap(cashAsset.currency, gap));
    }
    for(CashAsset lastCashAsset in lastCashAssetList) {
      bool hasExhaustedCash = true;
      for(CashAsset cashAsset in cashAssetList) {
        if(lastCashAsset.currency == cashAsset.currency) {
          hasExhaustedCash = false;
          break;
        }
      }
      if(hasExhaustedCash) {
        double gap = lastCashAsset.amount;
        for(CashDetail cashDetail in cashAssetDetailList) {
          if(lastCashAsset.currency == cashDetail.currency) {
            gap += cashDetail.amount;
          }
        }
        cashGapList.add(CashGap(lastCashAsset.currency, gap));
      }
    }
  }

  void checkInvestTax() {
    const String DOLLOR = '??????';
    investTax = 0;
    for(InvestAsset asset in investAssetList) {
      if(asset.currency == DOLLOR) {
        investTax += asset.getTotalRevenue();
      }
    }
    if(Database().exchangeRate.containsKey(DOLLOR)) {
      investTax *= Database().exchangeRate[DOLLOR]!.toDouble();
    }
    if(investTax > 2500000) {
      investTax = (investTax - 2500000) * 0.22;
    } else {
      investTax = 0;
    }
  }

  Widget loadingPage() {
    return Align(
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

  Widget mainPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    child: Text('????????????')),
                IconButton(
                  tooltip: '????????????',
                  icon: Icon(Icons.input),
                  onPressed: () {
                    setCurrency();
                  },
                )
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text('???/???: '),
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
                Text('??????:'),
                SizedBox(width: 20),
                getTextField(assetGoal, (newValue) => assetGoal = double.parse(newValue.replaceAll(',', ''))),
                SizedBox(width: 50),
                Text('???  (???'),
                SizedBox(width: 10),
                getTextField(monthGoal, (newValue) {
                  double newGoal = double.parse(newValue.replaceAll(',', ''));
                  monthGoal = newGoal;
                }),
                SizedBox(width: 5),
                Text('??????)'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('??????:    ${f.format(totalAsset)}   ???', textScaleFactor: 1.2),
                SizedBox(width: 30),
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    Text('????????????')
                  ],
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
                        Text('????????? ??????', textScaleFactor: 2),
                        SizedBox(width: 20),
                        Text('(???  ' + f.format(totalCash) + '  ???)', textScaleFactor: 1.5)
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
                        Text('?????? ?????????', textScaleFactor: 2),
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
                        Text('????????????', textScaleFactor: 2),
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
                          Text('??????', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 10),
                          cashGapList.length > 0 ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: cashGapList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                children: [
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
                        Text('????????????', textScaleFactor: 2),
                        SizedBox(width: 20),
                        Text('(???  ' + f.format(totalInvest) + '  ???)', textScaleFactor: 1.5),
                        SizedBox(width: 20),
                        Text('*??????????????????  ' + f.format(investTax.ceilToDouble()) + '  ??? ??????')
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
                        Text('????????????', textScaleFactor: 2),
                        SizedBox(width: 20),
                        Text('(???  ' + f.format(totalPension) + '  ???)', textScaleFactor: 1.5)
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        makeTable(PENSION_ASSET),
                        SizedBox(height: 20),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              pensionAssetList.add(PensionAsset(pensionAssetList.length));
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
                  getDialog('????????????', '????????????????', Colors.blue, (){
                    String month;
                    isInputMode? month = newMonth : month = thisMonth;
                    if(month.isNotEmpty) {
                      Database().saveAsset(context, isInputMode, month, assetGoal, monthGoal,
                          cashAssetList, cashAssetDetailList, investAssetList, pensionAssetList,
                          totalAsset, totalCash, totalInvest, totalPension
                      );
                    } else {
                      showAlert('???/?????? ???????????????.');
                    }
                  }),
                  SizedBox(width: 20),
                  getDialog('????????????', '????????????????', Colors.red, (){
                    if(isInputMode) {
                      showAlert('?????? ??????????????? ????????? ??? ????????????.');
                    } else {
                      Database().deleteMonth(context, thisMonth, cashAssetList);
                    }
                  })
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
              btnOkText: '???',
              btnCancelText: '?????????',
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

  AwesomeDialog setCurrency() {
    String oldCurrency = '';
    for(String str in Database().currencyList) {
      oldCurrency += '$str ';
    }
    String newCurrency = '';
    TextEditingController textFieldController = TextEditingController();
    textFieldController.addListener(() {
      newCurrency = textFieldController.text;
      print(newCurrency);
    });

    return AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.INFO,
        animType: AnimType.BOTTOMSLIDE,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                '?????? ??????',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(oldCurrency),
                ],
              ),
              SizedBox(height: 10),
              Material(
                elevation: 0,
                color: Colors.blueGrey.withAlpha(40),
                child: TextFormField(
                  autofocus: true,
                  minLines: 1,
                  controller: textFieldController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'new currency list',
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        btnOkText: '??????',
        btnCancelText: '??????',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          List<String> newCurrencyList = newCurrency.split(' ');
          Database().setCurrencyList(newCurrencyList);
        }
    )..show();
  }

  DataTable makeTable(String type) {
    List<DataColumn> dataColumn = [];
    List<DataRow> dataRow = [];

    switch (type) {
      case CASH_ASSET :
        List<String> columns = ['??????','??????','?????????','??????','????????????','',''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(cashAssetList.length, (index) {
          double variation = cashAssetList[index].amount;
          for(CashAsset lastCashAsset in lastCashAssetList) {
            if(lastCashAsset.currency == cashAssetList[index].currency) {
              variation = cashAssetList[index].amount - lastCashAsset.amount;
            }
          }
          return DataRow(
              cells: [
                DataCell(getDropDownButton(cashAssetList[index].currency, Database().currencyList, (newValue) => cashAssetList[index].currency = newValue)),
                DataCell(getTextField(cashAssetList[index].amount, (newValue) => cashAssetList[index].amount = double.parse(newValue.replaceAll(',', '')))),
                DataCell(Text(f.format(variation.round()))),
                DataCell(getTextField(cashAssetList[index].exchangeRate, (newValue) => cashAssetList[index].exchangeRate = double.parse(newValue.replaceAll(',', '')))),
                DataCell(Text(f.format((cashAssetList[index].amount * cashAssetList[index].exchangeRate).round()))),
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
        List<String> columns = ['??????','??????'];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(lastCashAssetList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(Text(lastCashAssetList[index].currency)),
                  DataCell(Text(f.format(lastCashAssetList[index].amount))),
                ]
            )
        );
        break;

      case CASH_DETAIL :
        List<String> columns = ['??????','??????','??????','',''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(cashAssetDetailList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getDropDownButton(cashAssetDetailList[index].currency, Database().currencyList, (newValue) => cashAssetDetailList[index].currency = newValue)),
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
        List<String> columns = ['??????','??????','?????????','?????????', '??????', '????????????', '?????????' ,'??????', '?????????', '??????','',''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(investAssetList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getDropDownButton(investAssetList[index].currency, Database().currencyList, (newValue) => investAssetList[index].currency = newValue)),
                  DataCell(getTextField(investAssetList[index].item, (newValue) => investAssetList[index].item = newValue)),
                  DataCell(getTextField(investAssetList[index].buyPrice, (newValue) => investAssetList[index].buyPrice = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(getTextField(investAssetList[index].currentPrice, (newValue) => investAssetList[index].currentPrice = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(getTextField(investAssetList[index].quantity, (newValue) => investAssetList[index].quantity = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(Text(f.format((investAssetList[index].getGrossPurchase()).round()))),
                  DataCell(Text(f.format((investAssetList[index].getGrossValue()).round()))),
                  DataCell(Text(f.format((investAssetList[index].getTotalRevenue()).round()))),
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

      case PENSION_ASSET :
        List<String> columns = ['??????','?????????','?????????','??????', '?????????', '??????','',''];
        dataColumn = List<DataColumn>.generate(columns.length, (index) => DataColumn(label: Text(columns[index])));
        dataRow = List<DataRow>.generate(pensionAssetList.length, (index) =>
            DataRow(
                cells: [
                  DataCell(getTextField(pensionAssetList[index].item, (newValue) => pensionAssetList[index].item = newValue)),
                  DataCell(getTextField(pensionAssetList[index].buyPrice, (newValue) => pensionAssetList[index].buyPrice = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(getTextField(pensionAssetList[index].currentPrice, (newValue) => pensionAssetList[index].currentPrice = double.parse(newValue.replaceAll(',', '')))),
                  DataCell(Text(f.format((pensionAssetList[index].getTotalRevenue()).round()))),
                  DataCell(Text(pensionAssetList[index].getEarningsRate())),
                  DataCell(getTextField(pensionAssetList[index].tag, (newValue) => pensionAssetList[index].tag = newValue)),
                  DataCell(IconButton(
                      onPressed: () {
                        setState(() {
                          pensionAssetList.removeAt(index);
                          for(int i=index; i<pensionAssetList.length; i++) {
                            pensionAssetList[i].no--;
                          }
                        });
                      },
                      icon: Icon(Icons.cancel_outlined, color: Colors.red))
                  ),
                  DataCell(getIndexEdit(index, (isUpside) {
                    if(isUpside && index != 0) {
                      setState(() {
                        pensionAssetList[index].no--;
                        pensionAssetList[index - 1].no++;
                        PensionAsset asset = pensionAssetList[index];
                        pensionAssetList.removeAt(index);
                        pensionAssetList.insert(index-1, asset);
                      });

                    } else if(!isUpside && index != pensionAssetList.length-1) {
                      setState(() {
                        pensionAssetList[index].no++;
                        pensionAssetList[index + 1].no--;
                        PensionAsset asset = pensionAssetList[index];
                        pensionAssetList.removeAt(index);
                        pensionAssetList.insert(index+1, asset);
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
      //inputFormatter.add(FilteringTextInputFormatter.digitsOnly); //todo: ???????????? ?????? ??????!!
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
