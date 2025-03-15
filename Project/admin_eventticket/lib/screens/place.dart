import 'package:admin_eventticket/main.dart';
import 'package:flutter/material.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  List<Map<String, dynamic>> placeList = [];
  List<Map<String, dynamic>> districtList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();
  String? selectedDistrict;

  Future<void> insertPlace() async {
    try {
      String name = _nameController.text;
      await supabase.from('tbl_place').insert({
        'place_name': name,
        'district_id': selectedDistrict,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Place Inserted Successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      fetchplace();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Insertion Failed. Please Try Again!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR ADDING PLACE: $e");
    }
  }

  Future<void> fetchdistrict() async {
    try {
      final response = await supabase.from("tbl_district").select();
      setState(() {
        districtList = response;
      });
    } catch (e) {}
  }

  Future<void> fetchplace() async {
    try {
      final response =
          await supabase.from("tbl_place").select("* ,tbl_district(*)");
      setState(() {
        placeList = response;
      });
    } catch (e) {}
  }

  Future<void> deletedplace(String did) async {
    try {
      await supabase.from("tbl_place").delete().eq("id", did);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Place Deleted Successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      fetchplace();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> editplace() async {
    try {
      await supabase.from("tbl_place").update({
        'place_name': _nameController.text,
      }).eq("id", editID);
      fetchplace();
      setState(() {
        editID = 0;
      });
      _nameController.clear();
    } catch (e) {
      print("Error editing: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchplace();
    fetchdistrict();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editID == 0 ? "Add Place" : "Edit Place",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        items: districtList.map((district) {
                          return DropdownMenuItem(
                            value: district["id"].toString(),
                            child: Text(district["district_name"]),
                          );
                        }).toList(),
                        value: selectedDistrict,
                        onChanged: (newValue) {
                          setState(() {
                            selectedDistrict = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Select District",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == "" || value!.isEmpty) {
                            return "Please enter a place";
                          }
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'Name must contain only alphabets';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Enter Place",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (editID == 0) {
                                insertPlace();
                              } else {
                                editplace();
                              }
                            }
                          },
                          child: Text(
                            editID == 0 ? "Add Place" : "Update Place",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Added Places",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 10),

                /// 📌 **Fixed-width DataTable**
                SizedBox(
                  width: double.infinity, // Fixes table width
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.blueGrey.shade100),
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columns: [
                      DataColumn(
                        label: Text(
                          "Place Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "District",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Actions",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: placeList.map((data) {
                      return DataRow(cells: [
                        DataCell(Text(data['place_name'])),
                        DataCell(Text(data['tbl_district']['district_name'])),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    editID = data['id'];
                                    _nameController.text = data['place_name'];
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deletedplace(data['id'].toString());
                                },
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
