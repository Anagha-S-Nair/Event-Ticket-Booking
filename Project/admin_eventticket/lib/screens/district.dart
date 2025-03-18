import 'package:admin_eventticket/main.dart';
import 'package:flutter/material.dart';

class District extends StatefulWidget {
  const District({super.key});

  @override
  State<District> createState() => _DistrictState();
}

class _DistrictState extends State<District> {
  List<Map<String, dynamic>> districtList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> insertDistrict() async {
    try {
      String name = _nameController.text;
      await supabase.from('tbl_district').insert({
        'district_name': name,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "District Inserted",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      fetchdistrict();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR ADDING DISTRICT: $e");
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

  Future<void> deletedistrict(String did) async {
    try {
      await supabase.from("tbl_district").delete().eq("id", did);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("District Deleted Successfully"),
        backgroundColor: Colors.red,
      ));
      fetchdistrict();
    } catch (e) {
      print("Error:$e");
    }
  }

  Future<void> editdistrict() async {
    try {
      await supabase.from("tbl_district").update({
        'district_name': _nameController.text,
      }).eq("id", editID);
      fetchdistrict();
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
    fetchdistrict();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      width: 500,
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              editID == 0 ? "Add District" : "Edit District",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              style: const TextStyle(color: Colors.black),
              validator: (value) {
                if (value == "" || value!.isEmpty) {
                  return "Please enter district";
                }
                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                  return 'Name must contain only alphabets';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: "District",
                hintText: "Enter district",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(112, 91, 74, 74),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (editID == 0) {
                    insertDistrict();
                  } else {
                    editdistrict();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "SUBMIT",
                style: TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Added Districts",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: districtList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final data = districtList[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      child: Text(
                        (index + 1).toString(), // Numbering logic
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      data['district_name'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              deletedistrict(data['id'].toString());
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                editID = data['id'];
                                _nameController.text = data['district_name'];
                              });
                            },
                            icon: const Icon(Icons.edit, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
