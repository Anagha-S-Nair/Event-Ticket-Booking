import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';

class MyRequests extends StatefulWidget {
  const MyRequests({super.key});

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  List<Map<String, dynamic>> eventList = [];

  Future<void> acceptrequest(int rid) async {
    try {
      await supabase
          .from('tbl_stallrequest')
          .update({'request_status': 1}).eq('id', rid);
      fetchrequest();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request accepted.")),
      );
    } catch (e) {
      print("Error updating : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to accept.")),
      );
    }
  }

  Future<void> rejectrequest(int rid) async {
    try {
      await supabase
          .from('tbl_stallrequest')
          .update({'request_status': 2}).eq('id', rid);
      fetchrequest();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request rejected.")),
      );
    } catch (e) {
      print("Error updating : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reject.")),
      );
    }
  }

  Future<void> fetchrequest() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase
          .from("tbl_stallrequest")
          .select(
              "*, tbl_event(*,tbl_place(*,tbl_district(*))), tbl_stallmanager(*),tbl_stalltype(*)")
          .eq("stallmanager_id", uid);
      setState(() {
        eventList = (response);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchrequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Requests',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white, // Professional dark tone
        elevation: 2,
        centerTitle: true,
      ),
      backgroundColor: Colors.white, // Subtle background for webpage feel
      body: ListView.builder(
        itemCount: eventList.length,
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        itemBuilder: (context, index) {
          final stall = eventList[index];
          print(stall['tbl_event']['event_photo']);
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Softer corners
            ),
            elevation: 5, // Slight shadow for depth
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 220,
                  height: 150, // Fixed height for consistency
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      stall['tbl_event']['event_photo'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16), // Consistent padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stall['tbl_event']['event_name'] ?? 'Unknown Event',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.store, size: 16, color: Colors.blueGrey[400]),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Stall Type: ${stall['tbl_stalltype']['stalltype_name'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.store, size: 16, color: Colors.blueGrey[400]),
                                SizedBox(width: 6),
                                Text(
                                  "Event Venue:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${stall['tbl_event']['tbl_place']['place_name'] ?? 'N/A'}, ${stall['tbl_event']['tbl_place']['tbl_district']['district_name'] ?? 'N/A'}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.blueGrey[400]),
                                SizedBox(width: 6),
                                Text(
                                  "Stall Details:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              stall['request_message'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, size: 16, color: Colors.blueGrey[400]),
                                SizedBox(width: 6),
                                Text(
                                  "Event Details:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              stall['tbl_event']['event_details'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 140,
                  height: 150, // Match image height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    color: Colors.white,
                    border: Border(
                      left: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: stall['request_status'] == 0
                              ? Colors.amber[700]
                              : stall['request_status'] == 1
                                  ? Colors.green[600]
                                  : Colors.red[600],
                        ),
                        child: Center(
                          child: Text(
                            stall['request_status'] == 0
                                ? "Pending"
                                : stall['request_status'] == 1
                                    ? "Approved"
                                    : "Rejected",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
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