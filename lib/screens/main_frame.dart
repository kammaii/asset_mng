import 'package:asset_mng/screens/assets.dart';
import 'package:asset_mng/screens/asset_flow.dart';
import 'package:asset_mng/screens/stock_scraping.dart';
import 'package:flutter/material.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {

  final List<Widget> _buildScreens = [
    StockScraping(),
    MainAssets(),
    AssetFlow(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            minWidth: 100,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search),
                label: Text('주식검색'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.attach_money_rounded),
                selectedIcon: Icon(Icons.attach_money_rounded),
                label: Text('자산'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.waves_rounded),
                selectedIcon: Icon(Icons.waves_rounded),
                label: Text('자산흐름'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
          ),
          Expanded(
            child: _buildScreens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
