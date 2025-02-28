import 'package:flutter/material.dart';

class EventDetails extends StatelessWidget {
  const EventDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                      image: NetworkImage(
                        'https://source.unsplash.com/600x400/?concert,music',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Event Title
                Text(
                  "National Music Festival",
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
                    Text("Monday, December 24, 2025"),
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
                    Text("18:00 - 23:00 PM GMT -07:00"),
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
                    Text("Rs20.00 - Rs100.00"),
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
                  "Experience an electrifying night at the RhythmWave Music Festival, where top artists and DJs will set the stage on fire with live performances, stunning visuals, and non-stop beats. Join us for an unforgettable celebration of music, food, and festival vibes under the open sky!",
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
      ),
    );
  }
}
