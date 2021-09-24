import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

class MainSearch extends StatefulWidget {
  const MainSearch({Key? key}) : super(key: key);

  @override
  _MainSearchState createState() => _MainSearchState();
}

class _MainSearchState extends State<MainSearch> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('button'),
        onPressed: () {
          extractData();
        },
      ),
    );
  }

  Future<List<String>> extractData() async {
//Getting the response from the targeted url
    final response =
    await http.Client().get(Uri.parse('https://www.geeksforgeeks.org/'), headers: {"Access-Control-Allow-Origin": "*"});
    //Status Code 200 means response has been received successfully
    if (response.statusCode == 200) {
      //Getting the html document from the response
      var document = parser.parse(response.body);
      try {
        //Scraping the first article title
        var responseString1 = document
            .getElementsByClassName('articles-list')[0]
            .children[0]
            .children[0]
            .children[0];

        print(responseString1.text.trim());

        //Scraping the second article title
        var responseString2 = document
            .getElementsByClassName('articles-list')[0]
            .children[1]
            .children[0]
            .children[0];

        print(responseString2.text.trim());

        //Scraping the third article title
        var responseString3 = document
            .getElementsByClassName('articles-list')[0]
            .children[2]
            .children[0]
            .children[0];

        print(responseString3.text.trim());
        //Converting the extracted titles into string and returning a list of Strings
        return [
          responseString1.text.trim(),
          responseString2.text.trim(),
          responseString3.text.trim()
        ];
      } catch (e) {
        return ['', '', 'ERROR!'];
      }
    } else {
      return ['', '', 'ERROR: ${response.statusCode}.'];
    }
  }
}
