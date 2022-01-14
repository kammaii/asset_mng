import 'package:http/http.dart' as http;

class ScrapingApi {
  Future<bool> getScraping() async {
    final url = "http://127.0.0.1:5001/asset-manager-271ba/us-central1/scraping";
    final response = await http.get(url);
    print('Response: $response');
    return true;
  }
}