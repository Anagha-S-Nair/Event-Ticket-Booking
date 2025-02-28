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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "StallType Inserted",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      fetchstalltype();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Deleted ")));
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
    // TODO: implement initState
    super.initState();
    fetchstalltype();
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
                    return "Please enter Stalltype";
                  }
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                    return 'Name must contain only alphabets';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Enter StallType",
                  hintStyle:
                      TextStyle(color: const Color.fromARGB(112, 91, 74, 74)),
                  border: OutlineInputBorder(),
                )),
            ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (editID == 0) {
                      insertstalltype();
                    } else {
                      editstalltype();
                    }
                  }
                },
                child: Text("Submit")),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: stalltypeList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final data = stalltypeList[index];
                return ListTile(
                  title: Text(data['stalltype_name']),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              deletestalltype(data['id'].toString());
                            },
                            icon: Icon(Icons.delete)),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                editID = data['id'];
                                _nameController.text = data['stalltype_name'];
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
