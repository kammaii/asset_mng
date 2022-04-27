import 'dart:convert';
import 'package:http/http.dart' as http;

//const basicUrl = "http://192.168.219.100:5001/asset-manager-271ba/us-central1";
const basicUrl = "https://us-central1-asset-manager-271ba.cloudfunctions.net";

class ScrapingApi {
  Future<bool> getScraping(dynamic stockCode) async {
    print(basicUrl+'/scraping?stockCode=' + stockCode);
    try{
      final response = await http.get(basicUrl+'/scraping?stockCode=' + stockCode);
      print('Response: ${response.body}');

    }catch(e){
      print('error:$e');
    }
    return true;
  }

  Future<List<dynamic>> getStockCodes() async{
    final response = await http.get(basicUrl+'/getStockCodes');
    print('getStockCodesResponse: $response');
    List<dynamic> stockCodes = jsonDecode(response.body);
    return stockCodes;
  }
}