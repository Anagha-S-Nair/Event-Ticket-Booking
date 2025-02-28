import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';

class StallEventDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const StallEventDetails({super.key, required this.data});

  @override
  State<StallEventDetails> createState() => _StallEventDetailsState();
}

class _StallEventDetailsState extends State<StallEventDetails> {
  List<Map<String, dynamic>> stallList = [];

  @override
  void initState() {
    super.initState();
    fetchstalltype(); // Fetch stall types when the page loads
  }

  Future<void> fetchstalltype() async {
    try {
      final response = await supabase.from("tbl_stalltype").select();
      setState(() {
        stallList = response;
      });
    } catch (e) {
      print("Error fetching stalltype: $e");
    }
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
      formattedTime = DateFormat('HH:mm:ss').format(eventTime);
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
                  left: 20,
                  top: 100,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Date: $formattedDate",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 18),
                            SizedBox(width: 8),
                            Text("Time: $formattedTime"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.timer, size: 18),
                            SizedBox(width: 8),
                            Text("Duration: ${widget.data['event_duration']}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      _showRequestDialog(context, widget.data['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Purple shade
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          "Apply Request",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      SizedBox(
                        width: 300,
                        height: 250,
                        child: Image.asset(
                          'assets/l8.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDialog(BuildContext context, int id) {
    String? selectedStall;
    final TextEditingController notesController = TextEditingController();

    Future<void> sendReq() async {
      try {
        print("Sending request for $selectedStall");
        print("Notes: ${notesController.text}");
        print("Event ID: $id");
        await supabase.from("tbl_stallrequest").insert([
          {
            'stallmanager_id': supabase.auth.currentUser!.id,
            "event_id": id,
            "stalltype_id": selectedStall,
            "request_message": notesController.text,
          }
        ]);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request sent for $selectedStall")),
        );
      } catch (e) {
        print("Error sending request: $e");
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Send Request"),
          content: FutureBuilder(
            future: fetchstalltype(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField(
                        items: stallList.map((stalltype) {
                          return DropdownMenuItem(
                            value: stalltype["id"].toString(),
                            child: Text(stalltype["stalltype_name"]),
                          );
                        }).toList(),
                        value: selectedStall,
                        onChanged: (newValue) {
                          setState(() {
                            selectedStall = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: notesController,
                        decoration: InputDecoration(
                          hintText: "Additional Notes",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedStall != null) {
                            sendReq();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please select a stall!")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF673AB7), // Purple color
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.send, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Apply Request",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
