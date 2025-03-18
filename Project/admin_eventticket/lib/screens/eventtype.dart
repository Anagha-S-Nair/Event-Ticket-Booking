import 'package:admin_eventticket/main.dart';
import 'package:flutter/material.dart';

class Eventtype extends StatefulWidget {
  const Eventtype({super.key});

  @override
  State<Eventtype> createState() => _EventypeState();
}

class _EventypeState extends State<Eventtype> {
  List<Map<String, dynamic>> eventtypeList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> inserteventtype() async {
    try {
      String name = _nameController.text;
      await supabase.from('tbl_eventtype').insert({
        'eventtype_name': name,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Event Inserted Successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      fetcheventtype();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Insertion Failed. Please Try Again!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR ADDING EVENT: $e");
    }
  }

  Future<void> fetcheventtype() async {
    try {
      final response = await supabase.from("tbl_eventtype").select();
      setState(() {
        eventtypeList = response;
      });
    } catch (e) {}
  }

  Future<void> deleteeventtype(String did) async {
    try {
      await supabase.from("tbl_eventtype").delete().eq("id", did);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Event Type Deleted Successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      fetcheventtype();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> editeventtype() async {
    try {
      await supabase.from("tbl_eventtype").update({
        'eventtype_name': _nameController.text,
      }).eq("id", editID);
      fetcheventtype();
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
    fetcheventtype();
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
                  editID == 0 ? "Add Event Type" : "Edit Event Type",
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
                            return "Please enter event type";
                          }
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'Name must contain only alphabets';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Enter Event Type",
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
                                inserteventtype();
                              } else {
                                editeventtype();
                              }
                            }
                          },
                          child: Text(
                            editID == 0 ? "Add Event Type" : "Update Event Type",
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Added Event Types",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),

                /// 📌 Styled List with Numbering
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eventtypeList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final data = eventtypeList[index];
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
                            (index + 1).toString(), // Display numbering
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          data['eventtype_name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  editID = data['id'];
                                  _nameController.text = data['eventtype_name'];
                                });
                              },
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () {
                                deleteeventtype(data['id'].toString());
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
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
