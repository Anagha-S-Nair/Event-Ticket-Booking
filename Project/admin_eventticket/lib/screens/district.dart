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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "District Inserted",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      fetchdistrict();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Deleted ")));
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
    // TODO: implement initState
    super.initState();
    fetchdistrict();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        width: 500,
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == "" || value!.isEmpty) {
                      return "Please enter district";
                    }
                    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                      return 'Name must contain only alphabets';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "District",
                    hintText: "Enter district",
                    hintStyle:
                        TextStyle(color: const Color.fromARGB(112, 91, 74, 74)),
                    border: OutlineInputBorder(),
                  )),
                  SizedBox(
                    height: 15,
                  ),
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
                  
                  child: Text("SUBMIT",
                  style: TextStyle(
                    fontSize: 15
                  ),
                  )
                  ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: districtList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final data = districtList[index];
                  return ListTile(
                    title: Text(data['district_name']),
                    trailing: SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                deletedistrict(data['id'].toString());
                              },
                              icon: Icon(Icons.delete)),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  editID = data['id'];
                                  _nameController.text = data['district_name'];
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
      ),
    );
  }
}
