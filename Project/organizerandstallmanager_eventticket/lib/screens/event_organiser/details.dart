import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/complaint.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/rating.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/stallrequests.dart';

class EventDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const EventDetails({super.key, required this.data});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {

  int tickets = 0;

  Future <void> getTicketCount() async {
    try {
      int availableTickets = widget.data['event_count'] ?? 0;
      final ticketSum = await supabase
          .from('tbl_eventbooking')
          .select('eventbooking_ticket')
          .eq('event_id', widget.data['id'])
          .eq('eventbooking_status', 1);

      final totalTickets = ticketSum.fold<int>(
          0, (sum, row) => sum + (row['eventbooking_ticket'] as int));
    setState(() {
      tickets = availableTickets - totalTickets;
    });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTicketCount();
  }



  @override
  Widget build(BuildContext context) {
    // Format date
    String formattedDate = "Invalid Date";
    try {
      DateTime eventDate =
          DateTime.parse(widget.data['event_date']); // Assumes 'YYYY-MM-DD'
      formattedDate = DateFormat('dd-MM-yy').format(eventDate);
    } catch (e) {
      print("Error parsing date: $e");
    }

    // Format time
    String formattedTime = "Invalid Time";
    try {
      DateTime eventTime = DateTime.parse(
          "1970-01-01 ${widget.data['event_time']}"); // Assumes 'HH:mm:ss'
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
                      image: NetworkImage(widget.data['event_photo']),
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
                    widget.data['event_name'],
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
                        Text('Duration: ${widget.data['event_duration']}'),
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
                          widget.data['event_details'],
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
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrganizerRatingsPage(
                                      organizerId: widget.data['organiser_id'])),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 19, 37, 82),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                          ),
                          child: Text(
                            "Rating",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ComplaintsPage(id: widget.data['id'],)
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 19, 37, 82),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                          ),
                          child: Text(
                            "Complaints",
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
                  tickets == 0 ? Text('No tickets available') : Text('Available Tickets: $tickets'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
