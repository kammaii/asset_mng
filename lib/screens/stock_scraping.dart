import 'package:asset_mng/scraping_api.dart';
import 'package:flutter/material.dart';

class StockScraping extends StatelessWidget {
  const StockScraping({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () async {
            List<dynamic> stockCodes = await ScrapingApi().getStockCodes();
            for (int i = 0; i < stockCodes.length; i = i + 10) {
              await runScraping(stockCodes, i, i + 10);
            }
          },
          child: Text('스크래핑 실행'),
        ),
      ],
    );
  }

  Future<bool> runScraping(List<dynamic> stockCodes, int startIndex, int endIndex) async {
    List<Future<bool>> results = [];
    for(int i=startIndex; i<endIndex && i<stockCodes.length; i++) {
      Future<bool> result = ScrapingApi().getScraping(stockCodes[i]);
      results.add(result);
    }
    await Future.wait(results);
    return Future.value(true);
  }
}
