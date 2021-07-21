import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'My Asset Manager',
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Asset Manager'),
        ),
        body: Center(
          child: ElevatedButton(
            child: Text('button'),
            onPressed: () {
              webScrapperTest();
            },
          ),
        ),
      ),
    );
  }

  void webScrapperTest() async {
    final rawUrl = 'https://unacademy.com/course/gravitation-for-iit-jee/D5A8YSAJ';
    final webScraper = WebScraper('https://unacademy.com');
    final endpoint = rawUrl.replaceAll('https://unacademy.com', '');

    if (await webScraper.loadWebPage(endpoint)) {
      final titleElements = webScraper.getElement(
          'div.Week__Wrapper-sc-1qeje5a-2 > a.Link__StyledAnchor-sc-1n9f3wx-0 '
              ' > div.ItemCard__ItemContainer-xrh60s-8 > div.ItemCard__ItemInfo-xrh60s-1'
              '> h3.H6-sc-1gn2suh-0',
          []);
      print(titleElements);
      final titleList = <String>[];
      titleElements.forEach((element) {
        final title = element['title'];
        titleList.add('$title');
      });
      print(titleList);
      // if (mounted)
      //   setState(() {
      //     this.titleList = titleList;
      //   });
    } else {
      print('Cannot load url');
    }
  }
}
