import 'package:flutter/material.dart';

class ManageOrganizers extends StatelessWidget {
  final List<Map<String, String>> organizers = [
    {
      "name": "John Doe",
      "email": "john@example.com",
      "district": "New York",
      "address": "123 Street",
      "contact": "9876543210",
      "photo": "assets/photo.png",
      "proof": "assets/proof.png"
    },
    {
      "name": "Jane Smith",
      "email": "jane@example.com",
      "district": "Los Angeles",
      "address": "456 Avenue",
      "contact": "8765432109",
      "photo": "assets/photo.png",
      "proof": "assets/proof.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Event Organizers")),
      body: Padding(
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
              rows: organizers.map((organizer) {
                return DataRow(cells: [
                  DataCell(Text(organizer["name"]!)),
                  DataCell(Text(organizer["email"]!)),
                  DataCell(Text(organizer["district"]!)),
                  DataCell(Text(organizer["address"]!)),
                  DataCell(Text(organizer["contact"]!)),
                  DataCell(Icon(Icons.image)), // Placeholder for photo
                  DataCell(Icon(Icons.file_present)), // Placeholder for proof
                  DataCell(
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Approve logic
                          },
                          child: Text("Approve"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                        SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () {
                            // Reject logic
                          },
                          child: Text("Reject"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
