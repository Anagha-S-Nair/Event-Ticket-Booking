import 'package:flutter/material.dart';
import 'package:admin_eventticket/main.dart';

class ManageStall extends StatefulWidget {
  @override
  State<ManageStall> createState() => _ManageStallState();
}

class _ManageStallState extends State<ManageStall> {
  List<Map<String, dynamic>> stallList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStall();
  }

  // Fetch Organizers from Supabase
  Future<void> fetchStall() async {
    try {
      final response = await supabase.from("tbl_stallmanager").select("*,tbl_place(*,tbl_district(*))")
          .eq('stallmanager_status', 0);

      print("Fetched Stall Data: $response"); // Debugging output

      setState(() {
        stallList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching stall: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Approve Organizer
  Future<void> approveStall(String rid) async {
    try {
      await supabase.from('tbl_stallmanager').update({'stallmanager_status': 1}).eq('id', rid);
      fetchStall();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Stallmanager approved.")),
      );
    } catch (e) {
      print("Error approving stall: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to approve stall.")),
      );
    }
  }

  // Reject Organizer
  Future<void> rejectStall(String rid) async {
    try {
      await supabase.from('tbl_stallmanager').update({'stallmanager_status': 2}).eq('id', rid);
      fetchStall();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Stallmanager rejected.")),
      );
    } catch (e) {
      print("Error rejecting stall: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reject stall.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Manage Stall Organizers"),
      backgroundColor: Colors.white),
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
                    rows: stallList.map((stall) {
                      return DataRow(cells: [
                        DataCell(Text(stall["stallmanager_name"] ?? 'N/A')),
                        DataCell(Text(stall["stallmanager_email"] ?? 'N/A')),
                        DataCell(Text(stall['tbl_place']['tbl_district']["district_name"] ?? 'N/A')),
                        DataCell(Text(stall["stallmanager_address"] ?? 'N/A')),
                        DataCell(Text(stall["stallmanager_contact"] ?? 'N/A')),

                        // Display Image for Photo
                        DataCell(stall["stallmanager_photo"] != null && stall["stallmanager_photo"].isNotEmpty
                            ? Image.network(
                                stall["stallmanager_photo"],
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image_not_supported, color: Colors.grey);
                                })
                            : Icon(Icons.image, color: Colors.grey)),

                        // Display Proof (Assuming it's a URL to a document)
                        DataCell(stall["stallmanager_proof"] != null && stall["stallmanager_proof"].isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.file_present, color: Colors.blue),
                                onPressed: () {
                                  print("Opening Proof: ${stall["stallmanager_proof"]}");
                                },
                              )
                            : Icon(Icons.file_present, color: Colors.grey)),

                        // Action Buttons
                        DataCell(
                          stall["status"] == 1
                              ? Container(
                                  color: Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text("Approved", style: TextStyle(color: Colors.white)),
                                )
                              : stall["status"] == 2
                                  ? Container(
                                      color: Colors.red,
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text("Rejected", style: TextStyle(color: Colors.white)),
                                    )
                                  : Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            approveStall(stall['id']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: Text("Approve"),
                                        ),
                                        SizedBox(width: 5),
                                        ElevatedButton(
                                          onPressed: () {
                                            rejectStall(stall['id']);
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
