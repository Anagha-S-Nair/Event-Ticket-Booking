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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Event Inserted",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      fetcheventtype();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Deleted ")));
      fetcheventtype();
    } catch (e) {
      print("Error:$e");
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
    // TODO: implement initState
    super.initState();
    fetcheventtype();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      
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
                    return "Please enter eventtype";
                  }
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                    return 'Name must contain only alphabets';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Enter eventtype",
                  hintStyle:
                      TextStyle(color: const Color.fromARGB(112, 91, 74, 74)),
                  border: OutlineInputBorder(),
                )),
            ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (editID == 0) {
                      inserteventtype();
                    } else {
                      editeventtype();
                    }
                  }
                },
                child: Text("Submit")),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: eventtypeList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final data = eventtypeList[index];
                return ListTile(
                  title: Text(data['eventtype_name']),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              deleteeventtype(data['id'].toString());
                            },
                            icon: Icon(Icons.delete)),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                editID = data['id'];
                                _nameController.text = data['eventtype_name'];
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
