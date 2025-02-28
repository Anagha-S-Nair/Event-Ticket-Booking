import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';

class StallRequets extends StatefulWidget {
  const StallRequets({super.key});

  @override
  State<StallRequets> createState() => _StallRequetsState();
}

class _StallRequetsState extends State<StallRequets> {
  List<Map<String, dynamic>> eventList = [];

  Future<void> acceptrequest(int rid) async {
    try {
      await supabase
          .from('tbl_stallrequest')
          .update({'request_status': 1})
          .eq('id', rid);
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
          .update({'request_status': 2})
          .eq('id', rid);
          fetchrequest();
       // Refresh UI after update
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
    .select("*, tbl_event(*), tbl_stallmanager(*),tbl_stalltype(*)")  // Fetching stall request along with event details
    .eq("tbl_event.organiser_id", uid);  // Correct way to filter nested fields

print(response);
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
        title: Text('Stall Managers Requests'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body:ListView.builder(
              itemCount: eventList.length,
              padding: EdgeInsets.all(10),
              itemBuilder: (context, index) {
                var stall = eventList[index];

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
                          image: DecorationImage(image: NetworkImage(stall['tbl_stallmanager']['stallmanager_photo']), fit: BoxFit.cover),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stall['tbl_stallmanager']['stallmanager_name'] ?? 'Unknown Manager',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.store, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    "Stall Type: ${stall['tbl_stalltype']['stalltype_name'] ?? 'N/A'}",
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    "Stall Details: ${stall['request_message'] ?? 'N/A'}",
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     Icon(Icons.phone, size: 16, color: Colors.grey),
                              //     SizedBox(width: 4),
                              //     Text(
                              //       "Contact: ${stall['contact_number'] ?? 'N/A'}",
                              //       style: TextStyle(fontSize: 14, color: Colors.grey),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 130,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        child: stall['request_status'] == 0 ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                acceptrequest(stall['id']);
                                
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text("Approve"),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text("Reject"),
                            ),
                          ],
                        ) : stall['request_status'] == 1 ? Container(
                          color: Colors.green,
                          child: Center(
                            child: Text("Approved", style: TextStyle(color: Colors.white)),
                          ),
                        ) : Container(
                          color: Colors.red,
                          child: Center(
                            child: Text("Rejected", style: TextStyle(color: Colors.white)),
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
