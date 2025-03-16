import 'package:flutter/material.dart';
import 'package:admin_eventticket/main.dart';

class RejectedOrganizers extends StatefulWidget {
  @override
  State<RejectedOrganizers> createState() => _RejectedOrganizersState();
}

class _RejectedOrganizersState extends State<RejectedOrganizers> {
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
      final response =
          await supabase.from("tbl_eventorganisers").select("*,tbl_place(*,tbl_district(*))")
          .eq('organisers_status', 2);

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
  Future<void> approveOrganizer(String rid) async {
    try {
      await supabase
          .from('tbl_eventorganisers')
          .update({'organisers_status': 1}).eq('id', rid);
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

 
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rejected Event Organizers")),
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
                        DataCell(
                            Text(organizer['tbl_place']['tbl_district']["district_name"] ?? 'N/A')),
                        DataCell(
                            Text(organizer["organisers_address"] ?? 'N/A')),
                        DataCell(
                            Text(organizer["organisers_contact"] ?? 'N/A')),

                        // Display Image for Photo
                        DataCell(organizer["organiser_photo"] != null &&
                                organizer["organiser_photo"].isNotEmpty
                            ? Image.network(organizer["organiser_photo"],
                                width: 50, height: 50,
                                errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.image_not_supported,
                                    color: Colors.grey);
                              })
                            : Icon(Icons.image, color: Colors.grey)),

                        // Display Proof (Assuming it's a URL to a document)
                        DataCell(organizer["organiser_proof"] != null &&
                                organizer["organiser_proof"].isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.file_present,
                                    color: Colors.blue),
                                onPressed: () {
                                  print(
                                      "Opening Proof: ${organizer["organiser_proof"]}");
                                },
                              )
                            : Icon(Icons.file_present, color: Colors.grey)),

                        // Action Buttons
                        DataCell(
                          organizer["status"] == 1
                              ? Container(
                                  color: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text("Approved",
                                      style: TextStyle(color: Colors.white)),
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
