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
        title: Text('My Requests'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: eventList.length,
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 15),
        itemBuilder: (context, index) {
          final stall = eventList[index];
          print(stall['tbl_event']['event_photo']);
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20), // Reduced margin
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Image.network(stall['tbl_event']['event_photo'], fit: BoxFit.cover,),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stall['tbl_event']['event_name'] ?? 'Unknown Event',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.store, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Stall Type: ${stall['tbl_stalltype']['stalltype_name'] ?? 'N/A'}",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.store, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  "Event Venue:",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              "${stall['tbl_event']['tbl_place']['place_name'] ?? 'N/A'}, ${stall['tbl_event']['tbl_place']['tbl_district']['district_name'] ?? 'N/A'}",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  "Stall Details:",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              stall['request_message'] ?? 'N/A',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  "Event Details:",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              stall['tbl_event']['event_details'] ?? 'N/A',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                        ),
                        border: Border(
                          left: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                      child: stall['request_status'] == 0
                          ? Container(
                              padding: EdgeInsets.all(10),
                              color: Colors.yellow,
                              child: Center(
                                child: Text("Pending",
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center),
                              ),
                            )
                          : stall['request_status'] == 1
                              ? Container(
                                  padding: EdgeInsets.all(10),
                                  color: Colors.green,
                                  child: Center(
                                    child: Text("Approved",
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center),
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.all(10),
                                  color: Colors.red,
                                  child: Center(
                                    child: Text("Rejected",
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
