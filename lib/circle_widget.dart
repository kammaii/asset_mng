import 'package:asset_mng/invest_asset.dart';
import 'package:asset_mng/pension_asset.dart';
import 'package:intl/intl.dart';
import 'cash_asset.dart';
import 'database.dart';

class CircleWidget {
  String title = '';
  List<String> itemList = [];
  List<double> priceList = [];
  List<double> percentList = [];
  var f = NumberFormat('###,###,###,###.##');
  Map<String, double> exchangeRate = {};


  setVariablesFromTag(dynamic asset, double total) {
    if (!itemList.contains(asset.tag)) {
      itemList.add(asset.tag);
      priceList.add(0);
      percentList.add(0);
    }
    int index = itemList.indexOf(asset.tag);
    double exPrice = priceList[index];
    double newPrice;
    const String DOLLOR = '달러';
    if(asset is InvestAsset) {
      if(asset.currency == DOLLOR) {
        newPrice = exPrice + (asset.currentPrice * asset.quantity * Database().exchangeRate[DOLLOR]!);
      } else {
        newPrice = exPrice + (asset.currentPrice * asset.quantity);
      }
    } else {
      newPrice = exPrice + asset.currentPrice;
    }
    priceList[index] = newPrice;
    percentList[index] = double.parse((newPrice / total * 100).toStringAsFixed(1));
  }

  setVariables(String item, double price, double total) {
    itemList.add(item);
    priceList.add(price);
    percentList.add(double.parse((price / total * 100).toStringAsFixed(1)));
  }

  CircleWidget(int type, int index, [String? detailTitle]) { // 0:총자산, 1:생활비, 2:투자자산, 3:연금자산

    double totalAsset = Database().totalAssetList[index];
    double totalCash = Database().totalCashAssetList[index];
    double totalInvest = Database().totalInvestAssetList[index];
    double totalPension = Database().totalPensionAssetList[index];

    switch (type) {
      case 0:
        title = '총자산';
        itemList = ['생활비','투자','연금'];
        priceList.add(Database().totalCashAssetList[index]);
        priceList.add(Database().totalInvestAssetList[index]);
        priceList.add(Database().totalPensionAssetList[index]);
        percentList.add(double.parse((totalCash/totalAsset*100).toStringAsFixed(1)));
        percentList.add(double.parse((totalInvest/totalAsset*100).toStringAsFixed(1)));
        percentList.add(double.parse((totalPension/totalAsset*100).toStringAsFixed(1)));
        break;

      case 1:
        title = '생활비';
        List<CashAsset> assetList = Database().cashList;
        for(CashAsset asset in assetList) {
          double price = asset.amount * asset.exchangeRate;
          setVariables(asset.currency, price, totalCash);
        }
        break;

      case 2:
        List<InvestAsset> assetList = Database().investList;
        if(detailTitle == null) {
          title = '투자자산';
          for (InvestAsset asset in assetList) {
            setVariablesFromTag(asset, totalInvest);
          }
        } else {
          title = detailTitle;
          for (InvestAsset asset in assetList) {
            setVariables(asset.item, asset.currentPrice, totalInvest);
          }
        }
        break;

      case 3:
        List<PensionAsset> assetList = Database().pensionList;
        if(detailTitle == null) {
          title = '연금자산';
          for (PensionAsset asset in assetList) {
            setVariablesFromTag(asset, totalPension);
          }
        } else {
          title = detailTitle;
          for (PensionAsset asset in assetList) {
            setVariables(asset.item, asset.currentPrice, totalPension);
          }
        }
        break;
    }
  }
}