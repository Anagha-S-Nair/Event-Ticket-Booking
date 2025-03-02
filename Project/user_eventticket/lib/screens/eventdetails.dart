import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const EventDetails({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Format date
    String formattedDate = "Invalid Date";
    try {
      DateTime eventDate = DateTime.parse(data['event_date']); // Assumes 'YYYY-MM-DD'
      formattedDate = DateFormat('EEEE, MMMM d, y').format(eventDate);
    } catch (e) {
      print("Error parsing date: $e");
    }

    // Format time
    String formattedTime = "Invalid Time";
    try {
      DateTime eventTime = DateTime.parse("1970-01-01 ${data['event_time']}"); // Assumes 'HH:mm:ss'
      formattedTime = DateFormat('HH:mm:ss').format(eventTime);
    } catch (e) {
      print("Error parsing time: $e");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.arrow_back, color: Colors.black),
        actions: [
          Icon(Icons.favorite_border, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image Box
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(data['event_photo']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Event Title
              Text(
                data['event_name'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16),

              // Event Date & Time with Circular Icon Background
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Grey Circle
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.calendar_today, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  Text(formattedDate), // Displays actual formatted event date
                ],
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Grey Circle
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.access_time, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  Text("Time: $formattedTime"),
                ],
              ),

              SizedBox(height: 16),

              // Event Location
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Grey Circle
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Grand Park, New York City, US",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Ticket Price
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Grey Circle
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.attach_money, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  Text(data['event_ticketprice'].toString()),
                ],
              ),

              SizedBox(height: 16),

              // About Event
              Text(
                "About Event",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                data['event_details'],
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 16),

              // Gallery Section
              Text(
                "Gallery (Pre-Event)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://source.unsplash.com/100x100/?music,festival',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://source.unsplash.com/100x100/?concert,people',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://source.unsplash.com/100x100/?dj,party',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32), // Space before button
            ],
          ),
        ),
      ),

      // Floating Book Event Button
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Handle button press
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded edges
              ),
              elevation: 4, // Shadow effect
            ),
            child: Text(
              "Book Event",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
