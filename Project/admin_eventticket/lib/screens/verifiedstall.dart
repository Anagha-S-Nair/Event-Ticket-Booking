import 'package:flutter/material.dart';
import 'package:admin_eventticket/main.dart';

class VerifiedStall extends StatefulWidget {
  @override
  State<VerifiedStall> createState() => _VerifiedStallState();
}

class _VerifiedStallState extends State<VerifiedStall> {
  List<Map<String, dynamic>> verifiedstallList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStall();
  }

  // Fetch Organizers from Supabase
  Future<void> fetchStall() async {
    try {
      final response = await supabase
          .from("tbl_stallmanager")
          .select("*,tbl_place(*,tbl_district(*))")
          .eq('stallmanager_status', 1);

      print("Fetched Stall Data: $response"); // Debugging output

      setState(() {
        verifiedstallList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching stall: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Reject Organizer
  Future<void> rejectStall(String rid) async {
    try {
      await supabase
          .from('tbl_stallmanager')
          .update({'stallmanager_status': 2}).eq('id', rid);
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
      appBar: AppBar(title: Text("Verified Stall Organizers")),
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
                    rows: verifiedstallList.map((stall) {
                      return DataRow(cells: [
                        DataCell(Text(stall["stallmanager_name"] ?? 'N/A')),
                        DataCell(Text(stall["stallmanager_email"] ?? 'N/A')),
                        DataCell(Text(stall['tbl_place']['tbl_district']
                                ["district_name"] ??
                            'N/A')),
                        DataCell(Text(stall["stallmanager_address"] ?? 'N/A')),
                        DataCell(Text(stall["stallmanager_contact"] ?? 'N/A')),

                        // Display Image for Photo
                        DataCell(stall["stallmanager_photo"] != null &&
                                stall["stallmanager_photo"].isNotEmpty
                            ? Image.network(stall["stallmanager_photo"],
                                width: 50, height: 50,
                                errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.image_not_supported,
                                    color: Colors.grey);
                              })
                            : Icon(Icons.image, color: Colors.grey)),

                        // Display Proof (Assuming it's a URL to a document)
                        DataCell(
                          stall["stallmanager_proof"] != null &&
                                  stall["stallmanager_proof"].isNotEmpty
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
                                              stall["stallmanager_proof"],
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
                                    stall["stallmanager_proof"],
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

                        // Action Buttons
                        DataCell(
                          stall["status"] == 2
                              ? Container(
                                  color: Colors.red,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text("Rejected",
                                      style: TextStyle(color: Colors.white)),
                                )
                              : Row(
                                  children: [
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
