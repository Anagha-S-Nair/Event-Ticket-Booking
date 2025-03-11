import 'package:flutter/material.dart';
import 'package:admin_eventticket/main.dart';

class ManageStall extends StatefulWidget {
  @override
  State<ManageStall> createState() => _ManageStallState();
}

class _ManageStallState extends State<ManageStall> {
  List<Map<String, dynamic>> organizerList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrganizers();
  }

  // Fetch Organizers from Supabase
  Future<void> fetchOrganizers() async {
    try {
      final response = await supabase.from("tbl_eventorganisers").select("*");

      print("Fetched Organizers Data: $response"); // Debugging output

      setState(() {
        organizerList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching organizers: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Approve Organizer
  Future<void> approveOrganizer(int id) async {
    try {
      await supabase.from('tbl_eventorganisers').update({'status': 1}).eq('id', id);
      fetchOrganizers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Organizer approved.")),
      );
    } catch (e) {
      print("Error approving organizer: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to approve organizer.")),
      );
    }
  }

  // Reject Organizer
  Future<void> rejectOrganizer(int id) async {
    try {
      await supabase.from('tbl_eventorganisers').update({'status': 2}).eq('id', id);
      fetchOrganizers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Organizer rejected.")),
      );
    } catch (e) {
      print("Error rejecting organizer: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reject organizer.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Event Organizers")),
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
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('District')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Contact')),
                      DataColumn(label: Text('Photo')),
                      DataColumn(label: Text('Proof')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: organizerList.map((organizer) {
                      return DataRow(cells: [
                        DataCell(Text(organizer["organisers_name"] ?? 'N/A')),
                        DataCell(Text(organizer["organisers_email"] ?? 'N/A')),
                        DataCell(Text(organizer["organisers_district"] ?? 'N/A')),
                        DataCell(Text(organizer["organisers_address"] ?? 'N/A')),
                        DataCell(Text(organizer["organisers_contact"] ?? 'N/A')),

                        // Display Image for Photo
                        DataCell(organizer["organisers_photo"] != null && organizer["organisers_photo"].isNotEmpty
                            ? Image.network(
                                organizer["organisers_photo"],
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image_not_supported, color: Colors.grey);
                                })
                            : Icon(Icons.image, color: Colors.grey)),

                        // Display Proof (Assuming it's a URL to a document)
                        DataCell(organizer["organisers_proof"] != null && organizer["organisers_proof"].isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.file_present, color: Colors.blue),
                                onPressed: () {
                                  print("Opening Proof: ${organizer["organisers_proof"]}");
                                },
                              )
                            : Icon(Icons.file_present, color: Colors.grey)),

                        // Action Buttons
                        DataCell(
                          organizer["status"] == 1
                              ? Container(
                                  color: Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text("Approved", style: TextStyle(color: Colors.white)),
                                )
                              : organizer["status"] == 2
                                  ? Container(
                                      color: Colors.red,
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text("Rejected", style: TextStyle(color: Colors.white)),
                                    )
                                  : Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            approveOrganizer(organizer['id']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: Text("Approve"),
                                        ),
                                        SizedBox(width: 5),
                                        ElevatedButton(
                                          onPressed: () {
                                            rejectOrganizer(organizer['id']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: Text("Reject"),
                                        ),
                                      ],
                                    ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
