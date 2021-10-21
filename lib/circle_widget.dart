import 'package:asset_mng/invest_asset.dart';
import 'package:asset_mng/pension_asset.dart';
import 'package:intl/intl.dart';
import 'cash_asset.dart';
import 'database.dart';

class CircleWidget {
  late String title;
  late List<String> itemList;
  late List<String> priceList;
  late List<double> percentList;
  var f = NumberFormat('###,###,###,###.##');

  Map<String, double> getPriceFromTag(dynamic asset) {
    Map<String, double> priceMap = {};
    if (!itemList.contains(asset.tag)) {
      itemList.add(asset.tag);
      priceMap[asset.tag] = 0;
    }
    double exPrice;
    priceMap[asset.tag] == null ? exPrice = 0 : exPrice = priceMap[asset.tag]!;
    double newPrice = exPrice + asset.currentPrice;
    priceMap[asset.tag] = newPrice;
    return priceMap;
  }

  setVariables(String item, double price, double total) {
    itemList.add(item);
    priceList.add('(${f.format(price)} 원)');
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
        priceList.add('(${f.format(Database().totalCashAssetList[index])} 원)');
        priceList.add('(${f.format(Database().totalInvestAssetList[index])} 원)');
        priceList.add('(${f.format(Database().totalPensionAssetList[index])} 원)');
        percentList.add(double.parse((totalCash/totalAsset*100).toStringAsFixed(1)));
        percentList.add(double.parse((totalInvest/totalAsset*100).toStringAsFixed(1)));
        percentList.add(double.parse((totalPension/totalAsset*100).toStringAsFixed(1)));
        break;

      case 1:
        title = '생활비';
        List<CashAsset> assetList = Database().cashList;
        for(CashAsset asset in assetList) {
          setVariables(asset.currency, asset.amount, totalCash);
        }
        break;

      case 2:
        List<InvestAsset> assetList = Database().investList;
        if(detailTitle == null) {
          title = '투자자산';
          Map<String, double> priceMap = {};
          for (InvestAsset asset in assetList) {
            priceMap = getPriceFromTag(asset);
          }
          priceMap.forEach((key, value) {
            setVariables(key, value, totalInvest);
          });

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
          Map<String, double> priceMap = {};
          for (PensionAsset asset in assetList) {
            priceMap = getPriceFromTag(asset);
          }
          priceMap.forEach((key, value) {
            setVariables(key, value, totalPension);
          });

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