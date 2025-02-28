import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/stallrequests.dart';

class EventDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const EventDetails({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Format date
    String formattedDate = "Invalid Date";
    try {
      DateTime eventDate =
          DateTime.parse(data['event_date']); // Assumes 'YYYY-MM-DD'
      formattedDate = DateFormat('dd-MM-yy').format(eventDate);
    } catch (e) {
      print("Error parsing date: $e");
    }

    // Format time
    String formattedTime = "Invalid Time";
    try {
      DateTime eventTime = DateTime.parse(
          "1970-01-01 ${data['event_time']}"); // Assumes 'HH:mm:ss'
      formattedTime = DateFormat('HH-mm-ss').format(eventTime);
    } catch (e) {
      print("Error parsing time: $e");
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(data['event_photo']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  color: Colors.black.withOpacity(0.5),
                ),
                Positioned(
                  top: 200,
                  left: 20,
                  child: Text(
                    data['event_name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  right: 200,
                  top: 100,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Date: $formattedDate", // Formatted date
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Time: $formattedTime'), // Formatted time
                        SizedBox(height: 10),
                        Text('Duration: ${data['event_duration']}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 300,
                    child: Column(
                      children: [
                        Text(
                          "Event Overview",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          data['event_details'],
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StallRequets()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 19, 37, 82),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                          ),
                          child: Text(
                            "StallRequests",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('assets/l8.jpg', height: 250, fit: BoxFit.cover),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
