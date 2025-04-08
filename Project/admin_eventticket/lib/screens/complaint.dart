import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin_eventticket/main.dart';

class ManageComplaints extends StatefulWidget {
  @override
  State<ManageComplaints> createState() => _ManageComplaintsState();
}

class _ManageComplaintsState extends State<ManageComplaints> {
  List<Map<String, dynamic>> complaintList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  // Fetch Complaints from Supabase
  Future<void> fetchComplaints() async {
    try {
      final response = await supabase
          .from("tbl_complaint")
          .select("*,tbl_user(*),tbl_event(*,tbl_eventorganisers(*))");

      print("Fetched Complaints Data: $response"); // Debugging output

      setState(() {
        complaintList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching complaints: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          AppBar(title: Text("Manage Complaints"), backgroundColor: Colors.white),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('User Name')),
                      DataColumn(label: Text('Event Name')),
                      DataColumn(label: Text('Organiser')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Photo')),
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Reply')),
                    ],
                    rows: complaintList.map((complaint) {
                      return DataRow(cells: [
                        DataCell(Text(formatDate(complaint["complaint_date"] ?? ''))),
                        DataCell(Text(complaint['tbl_user']["user_name"] ?? 'N/A')),
                        DataCell(Text(complaint['tbl_event']["event_name"] ?? 'N/A')),
                        DataCell(Text(complaint['tbl_event']['tbl_eventorganisers']
                                ["organisers_name"] ??
                            'N/A')),
                        DataCell(Text(complaint['tbl_event']['tbl_eventorganisers']
                                ["organisers_email"] ??
                            'N/A')),
                        // DataCell(
                        //   complaint['tbl_event']["event_photo"] != null
                        //       ? Image.network(
                        //           complaint['tbl_event']["event_photo"],
                        //           width: 50,
                        //           height: 50,
                        //         )
                        //       : Text('N/A'),
                        // ),
                        DataCell(
                          complaint['tbl_event']["event_photo"] != null &&
                                  complaint['tbl_event']["event_photo"].isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            width:
                                                300, // Adjust width as needed
                                            height:
                                                300, // Adjust height as needed
                                            child: Image.network(
                                              complaint['tbl_event']["event_photo"],
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Center(
                                                  child: Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 50,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Image.network(
                                    complaint['tbl_event']["event_photo"],
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.file_download,
                                          color: Colors.grey);
                                    },
                                  ),
                                )
                              : Icon(Icons.image, color: Colors.grey),
                        ),
                        DataCell(Text(complaint["complaint_title"] ?? 'N/A')),
                        DataCell(Text(complaint["complaint_content"] ?? 'N/A')),
                        DataCell(Text(complaint["complaint_reply"] ?? 'N/A')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
