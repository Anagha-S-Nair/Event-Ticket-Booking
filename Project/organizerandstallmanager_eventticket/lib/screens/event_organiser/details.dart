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

  Future<void> getTicketCount() async {
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
    super.initState();
    getTicketCount();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = "Invalid Date";
    try {
      DateTime eventDate = DateTime.parse(widget.data['event_date']);
      formattedDate = DateFormat('dd-MM-yy').format(eventDate);
    } catch (e) {
      print("Error parsing date: $e");
    }

    String formattedTime = "Invalid Time";
    try {
      DateTime eventTime =
          DateTime.parse("1970-01-01 ${widget.data['event_time']}");
      formattedTime = DateFormat('HH:mm:ss').format(eventTime);
    } catch (e) {
      print("Error parsing time: $e");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          // widget.data['event_name'],
          "Event Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // backgroundColor: const Color.fromARGB(255, 19, 37, 82),
        // foregroundColor: Colors.white,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Event Image with Overlay
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(widget.data['event_photo']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black.withOpacity(0.4),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    widget.data['event_name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Event Info Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.calendar_today, "Date", formattedDate),
                    _buildInfoRow(Icons.access_time, "Time", formattedTime),
                    _buildInfoRow(Icons.hourglass_bottom, "Duration",
                        widget.data['event_duration']),
                    _buildInfoRow(Icons.confirmation_num_outlined, "Tickets",
                        tickets == 0
                            ? 'No tickets available'
                            : 'Available Tickets: $tickets'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Event Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Event Overview",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 19, 37, 82),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.data['event_details'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Buttons Section
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildActionButton("Stall Requests", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StallRequets(),
                      ),
                    );
                  }),
                  _buildActionButton("Ratings", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrganizerRatingsPage(
                            organizerId: widget.data['organiser_id']),
                      ),
                    );
                  }),
                  _buildActionButton("Complaints", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ComplaintsPage(id: widget.data['id']),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Info Row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 19, 37, 82)),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Action Buttons
  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 19, 37, 82),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}
