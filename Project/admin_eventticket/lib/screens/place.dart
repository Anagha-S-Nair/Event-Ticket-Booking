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
  Future<void> insertPlace() async {
    try {
      String name = _nameController.text;
      await supabase.from('tbl_place').insert({
        'place_name': name,
        'district_id':selectedDistrict,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Place Inserted",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      fetchplace();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
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
      final response = await supabase.from("tbl_place").select("* ,tbl_district(*)");
      setState(() {
        placeList = response;
      });
    } catch (e) {}
  }

  Future<void> deletedplace(String did) async {
    try {
      await supabase.from("tbl_place").delete().eq("id", did);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Deleted ")));
      fetchplace();
    } catch (e) {
      print("Error:$e");
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

  String? selectedDistrict;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchplace();
    fetchdistrict();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            DropdownButtonFormField(
              items: districtList.map((district) {
                return DropdownMenuItem(
                  value: district["id"].toString(),
                  child: Text(district["district_name"]));
              }).toList(),
               value: selectedDistrict,
              onChanged: (newValue) {
                  setState(() {
                    selectedDistrict = newValue;
                  });
                },
              decoration: InputDecoration(
                hintText: "Select District",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                style: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == "" || value!.isEmpty) {
                    return "Please enter place";
                  }
                  if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                    return 'Name must contain only alphabets';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Enter place",
                  hintStyle:
                      TextStyle(color: const Color.fromARGB(112, 91, 74, 74)),
                  border: OutlineInputBorder(),
                )),
            ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (editID == 0) {
                      insertPlace();
                    } else {
                      editplace();
                    }
                  }
                },
                child: Text("Submit")),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: placeList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final data = placeList[index];
                return ListTile(
                  title: Text(data['place_name']),
                  subtitle: Text(data['tbl_district']['district_name']),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              deletedplace(data['id'].toString());
                            },
                            icon: Icon(Icons.delete)),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                editID = data['id'];
                                _nameController.text = data['place_name'];
                              });
                            },
                            icon: Icon(Icons.edit))
                      ],
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
