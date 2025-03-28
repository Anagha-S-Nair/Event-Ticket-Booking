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
      final response =
          await supabase.from("tbl_event").select().eq('organiser_id', uid);
      setState(() {
        eventList = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchevent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("My Events",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        
        elevation: 4,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Createevent()));
            },
            icon: Icon(Icons.add, color: Colors.black),
            label: Text(
              "Create",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            style: ButtonStyle(
                overlayColor:
                    MaterialStateProperty.all(Colors.white.withOpacity(0.1))),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
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
                      builder: (context) => EventDetails(data: data),
                    ));
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(data['event_photo'] ?? ""),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    data['event_name'] ?? "No Name",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
