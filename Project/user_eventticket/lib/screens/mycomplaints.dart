import 'package:flutter/material.dart';
import 'package:user_eventticket/main.dart';
import 'package:intl/intl.dart';

class MyComplaintsPage extends StatefulWidget {
  const MyComplaintsPage({super.key});

  @override
  State<MyComplaintsPage> createState() => _MyComplaintsPageState();
}

class _MyComplaintsPageState extends State<MyComplaintsPage> {
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      String userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_complaint')
          // .select('complaint_title, complaint_reply, complaint_date, tbl_event(event_photo)')
          .select(
              'complaint_title, complaint_reply, complaint_date, complaint_status, tbl_event(event_photo)')
          .eq('user_id', userId);

      setState(() {
        complaints = List<Map<String, dynamic>>.from(response).map((complaint) {
          final originalDate = complaint['complaint_date'];
          DateTime parsedDate = DateTime.parse(originalDate);

          complaint['formatted_date'] =
              DateFormat('yy-MM-dd').format(parsedDate);
          complaint['formatted_time'] =
              DateFormat('HH:mm:ss').format(parsedDate);

          return complaint;
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load complaints.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Complaints"),
        backgroundColor: const Color.fromARGB(255, 2, 0, 108),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? const Center(
                  child: Text(
                    "No complaints submitted yet.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            complaint['tbl_event']['event_photo'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image,
                                    size: 60, color: Colors.grey),
                          ),
                        ),
                        title: Text(
                          complaint['complaint_title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${complaint['formatted_date']} ${complaint['formatted_time']}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            complaint['complaint_status'] == 0 ? Text('Organiser has not viewed your complaint yet') : Text(complaint['complaint_reply']),
                            // Text(
                            //   "Reply: ${complaint['complaint_reply']?.isNotEmpty == 1 ? complaint['complaint_reply'] : (complaint['complaint_status'] == 0 ? 'Your complaint is not viewed yet' : 'No reply yet')}",
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     color:
                            //         complaint['complaint_reply']?.isNotEmpty ==
                            //                 true
                            //             ? Colors.black87
                            //             : Colors.grey,
                            //   ),
                            // )
                          ],
                        ),
                        trailing: Text(
                          complaint['complaint_status'] == 1
                              ? "Resolved"
                              : "Pending",
                          style: TextStyle(
                            color: complaint['complaint_status'] == 1
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
