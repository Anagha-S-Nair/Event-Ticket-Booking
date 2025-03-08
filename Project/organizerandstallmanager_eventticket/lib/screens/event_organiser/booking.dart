import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Map<String, dynamic>> bookingList = [];

  
  Future<void> fetchbooking() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase
          .from("tbl_eventbooking")
          .select(
              "*, tbl_event(*), tbl_user(*)") // Fetching stall request along with event details
          .eq("tbl_event.organiser_id",
              uid).eq("eventbooking_status", 1); // Correct way to filter nested fields

      print(response);
      setState(() {
        bookingList = (response);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchbooking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Booking'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: bookingList.length,
        padding: EdgeInsets.all(10),
        itemBuilder: (context, index) {
          print(bookingList.length);
          final stall = bookingList[index];
          print(stall);
          print(stall['tbl_user']['user_photo']);
          String image = stall['tbl_user']['user_photo'] ?? "";
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    
                    image: image != '' ?  DecorationImage(
                        image: NetworkImage(
                            image),
                        fit: BoxFit.cover) : null,
                  ),
                  child: image != '' ? null : Center(child: Icon(Icons.image_not_supported_sharp),) 
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stall['tbl_user']['user_name'] ??
                              'Unknown Manager',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.store, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              "Event: ${stall['tbl_event']['event_name'] ?? 'N/A'}",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              "Ticket Count: ${stall['eventbooking_ticket'] ?? 'N/A'}",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
