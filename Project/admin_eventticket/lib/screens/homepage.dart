
import 'package:admin_eventticket/screens/rejectedorganiser.dart';
import 'package:admin_eventticket/screens/rejectedstall.dart';
import 'package:admin_eventticket/screens/stallmanager.dart';
import 'package:admin_eventticket/screens/verifiedorganiser.dart';
import 'package:admin_eventticket/screens/verifiedstall.dart';
import 'package:flutter/material.dart';
import 'package:admin_eventticket/screens/account.dart';
import 'package:admin_eventticket/screens/dashboard.dart';
import 'package:admin_eventticket/screens/district.dart';
import 'package:admin_eventticket/screens/eventorganiser.dart';
import 'package:admin_eventticket/screens/eventtype.dart';
import 'package:admin_eventticket/screens/place.dart';
import 'package:admin_eventticket/screens/stalltype.dart';
import 'package:admin_eventticket/screens/complaint.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<String> pageName = [
    'Dashboard',
    'Account',
    'District',
    'Place',
    'Event Type',
    'Stall Type',
    'Event Organiser',
    'Verified Organiser',
    'Rejectied Organiser',
    'Stall Manager',
    'Verified Stall',
    'Rejected Stall',
    'Complaint',
  ];

  final List<IconData> pageIcon = [
    Icons.dashboard,
    Icons.supervised_user_circle,
    Icons.location_city,
    Icons.place,
    Icons.event,
    Icons.store,
    Icons.group,
    Icons.verified_user,
    Icons.report_off,
    Icons.storefront,
    Icons.verified,
    Icons.report_off_rounded,
    Icons.report,
  ];

  final List<Widget> pageContent = [
    Dashboard(),
    Account(),
    District(),
    Place(),
    Eventtype(),
    Stalltype(),
    ManageOrganizers(),
    VerifiedOrganiser(),
    RejectedOrganizers(),
    ManageStall(),
    VerifiedStall(),
    RejectedStall(),
    ComplaintPage( eventId: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blueGrey),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Admin Panel",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.white54, thickness: 1, indent: 20, endIndent: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: pageName.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedIndex == index;
                      return ListTile(
                        leading: Icon(
                          pageIcon[index],
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                        title: Text(
                          pageName[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: Colors.blueGrey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Page Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: pageContent[selectedIndex],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
