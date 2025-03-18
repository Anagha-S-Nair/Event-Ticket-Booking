import 'package:admin_eventticket/main.dart';
import 'package:flutter/material.dart';

class Stalltype extends StatefulWidget {
  const Stalltype({super.key});

  @override
  State<Stalltype> createState() => _StalltypeState();
}

class _StalltypeState extends State<Stalltype> {
  List<Map<String, dynamic>> stalltypeList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> insertstalltype() async {
    try {
      String name = _nameController.text;
      await supabase.from('tbl_stalltype').insert({
        'stalltype_name': name,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Stall Type Inserted",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      fetchstalltype();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR ADDING STALLTYPE: $e");
    }
  }

  Future<void> fetchstalltype() async {
    try {
      final response = await supabase.from("tbl_stalltype").select();
      setState(() {
        stalltypeList = response;
      });
    } catch (e) {}
  }

  Future<void> deletestalltype(String did) async {
    try {
      await supabase.from("tbl_stalltype").delete().eq("id", did);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Stall Type Deleted Successfully"),
        backgroundColor: Colors.red,
      ));
      fetchstalltype();
    } catch (e) {
      print("Error:$e");
    }
  }

  Future<void> editstalltype() async {
    try {
      await supabase.from("tbl_stalltype").update({
        'stalltype_name': _nameController.text,
      }).eq("id", editID);
      fetchstalltype();
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
    fetchstalltype();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editID == 0 ? "Add Stall Type" : "Edit Stall Type",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == "" || value!.isEmpty) {
                            return "Please enter Stall Type";
                          }
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'Name must contain only alphabets';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Enter Stall Type",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (editID == 0) {
                                insertstalltype();
                              } else {
                                editstalltype();
                              }
                            }
                          },
                          child: Text(
                            editID == 0 ? "Add Stall Type" : "Update Stall Type",
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Added Stall Types",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stalltypeList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final data = stalltypeList[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          data['stalltype_name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: SizedBox(
                          width: 80,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  deletestalltype(data['id'].toString());
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    editID = data['id'];
                                    _nameController.text = data['stalltype_name'];
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
