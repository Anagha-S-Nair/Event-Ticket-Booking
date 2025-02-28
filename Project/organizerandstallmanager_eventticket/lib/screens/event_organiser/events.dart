import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/homepage.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/createevent.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/details.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Map<String, dynamic>> eventList = [];

  Future<void> fetchevent() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase.from("tbl_event").select().eq('organiser_id', uid);
      setState(() {
        eventList = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchevent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events"),
        backgroundColor: Colors.blue,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Createevent()));
            },
            child: Row(
              children: [
                Text(
                  "Create",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(width: 3),
                Icon(Icons.add, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: eventList.length,
          itemBuilder: (context, index) {
            final data = eventList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetails(data: data,),
                    ));
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        data['event_photo'] ?? "",
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['event_name'] ?? "",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: Divider(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Type", style: TextStyle(fontSize: 12)),
                              Text("City",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
