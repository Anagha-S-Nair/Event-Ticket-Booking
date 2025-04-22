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
    fetchstalltype();
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
    String formattedDate = "Invalid Date";
    try {
      DateTime eventDate =
          DateTime.parse(widget.data['event_date']);
      formattedDate = DateFormat('dd-MM-yy').format(eventDate);
    } catch (e) {
      print("Error parsing date: $e");
    }

    String formattedTime = "Invalid Time";
    try {
      DateTime eventTime = DateTime.parse(
          "1970-01-01 ${widget.data['event_time']}");
      formattedTime = DateFormat('HH:mm:ss').format(eventTime);
    } catch (e) {
      print("Error parsing time: $e");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Event Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                    _buildInfoRow(Icons.timer, "Duration",
                        widget.data['event_duration']),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
              ElevatedButton(
  onPressed: () {
    _showRequestDialog(context, widget.data['id']);
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 19, 37, 82), // Dark blue color
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  child: const Row(
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
)

            ],
          ),
        ),
      ),
    );
  }

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

  void _showRequestDialog(BuildContext context, int id) {
    String? selectedStall;
    final TextEditingController notesController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    Future<void> sendReq() async {
      try {
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
          title: const Text("Send Request"),
          content: FutureBuilder(
            future: fetchstalltype(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return StatefulBuilder(
                builder: (context, setState) {
                  return Form(
                    key: _formKey,
                    child: Column(
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
                          validator: (value) =>
                              value == null ? "Please select a stall type" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            hintText: "Additional Notes",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter a note";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              sendReq();
                            }
                          },
                          child: const Text("Submit Request"),
                        ),
                      ],
                    ),
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
