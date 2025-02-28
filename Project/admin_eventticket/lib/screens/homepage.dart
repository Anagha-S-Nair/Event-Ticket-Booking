import 'package:admin_eventticket/screens/account.dart';
import 'package:admin_eventticket/screens/dashboard.dart';
import 'package:admin_eventticket/screens/district.dart';
import 'package:admin_eventticket/screens/eventorganiser.dart';
import 'package:admin_eventticket/screens/eventtype.dart';
import 'package:admin_eventticket/screens/place.dart';
import 'package:admin_eventticket/screens/stalltype.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  List<String> pageName = [
    'Dashbard',
    'Account',
    'District',
    'Place',
    'Eventtype',
    'StallType',
    'EventOrganiser',
    'StallManager'
    
  ];
  List<IconData> pageIcon = [
    Icons.home,
    Icons.supervised_user_circle,
    Icons.location_city,
    Icons.place,
    Icons.event,
    Icons.store,
    Icons.group,
    Icons.storefront,

  ];

  List<Widget> pageContent = [
    Dashboard(),
    Account(),
    District(),
    Place(),
    Eventtype(),
    Stalltype(),
    ManageOrganizers(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue,
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: pageName.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          setState(() {
                            print(index);
                            selectedIndex = index;
                          });
                        },
                        leading: Icon(pageIcon[index]),
                        title: Text(pageName[index]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: pageContent[selectedIndex],
            ),
          )
        ],
      ),
    );
  }
}
