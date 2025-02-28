import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:file_picker/file_picker.dart';

class Organsierregistration extends StatefulWidget {
  const Organsierregistration({super.key});

  @override
  State<Organsierregistration> createState() => _OrgansierregistrationState();
}

class _OrgansierregistrationState extends State<Organsierregistration> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _proof = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  String? selectedDistrict;
  String? selectedPlace;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> placeList = [];
  List<Map<String, dynamic>> districtList = [];

  PlatformFile? pickedImage;
  PlatformFile? pickedProof;

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<void> handleProofPick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedProof = result.files.first;
        _proof.text = result.files.first.name;
      });
    }
  }

  Future<String?> photoUpload(String uid) async {
    try {
      final bucketName = 'organisers'; // Replace with your bucket name
      final filePath = "$uid-photo-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      // await updateImage(uid, publicUrl);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<String?> proofUpload(String uid) async {
    try {
      final bucketName = 'organisers'; // Replace with your bucket name
      final filePath = "$uid-proof-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      // await updateImage(uid, publicUrl);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<void> fetchdistrict() async {
    try {
      final response = await supabase.from("tbl_district").select();
      setState(() {
        districtList = response;
      });
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }

  Future<void> fetchplace(String id) async {
    try {
      final response =
          await supabase.from("tbl_place").select().eq("district_id", id);
      setState(() {
        placeList = response;
        selectedPlace = null; // Reset the selected place when district changes
      });
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  Future<void> reg() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final authentication = await supabase.auth
            .signUp(password: _password.text, email: _email.text);
        String uid = authentication.user!.id;
        storeData(uid);
      } catch (e) {
        print("Error Authentication: $e");
      }
    }
  }

  Future<void> storeData(String uid) async {
    try {
      String? photoUrl = await photoUpload(uid);
      String? proofUrl = await proofUpload(uid);
      await supabase.from("tbl_eventorganisers").insert({
        'id': uid,
        'organisers_name': _name.text,
        'organisers_email': _email.text,
        'organisers_address': _address.text,
        'organisers_password': _password.text,
        'organisers_contact': _contact.text,
        'place_id': selectedPlace,
        'organiser_photo': photoUrl,
        'organiser_proof': proofUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Inserted",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchdistrict();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF1E1E2E),
              // image: DecorationImage(
              //   image: AssetImage('assets/l8.jpg'), // Make sure the image is in your assets folder
              //   fit: BoxFit.cover, // This makes the image cover the entire screen
              // ),
            ),
          ),
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Center(
                child: Container(
                  width: 500,
                  height: 800,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: pickedImage == null
                            ? GestureDetector(
                                onTap: handleImagePick,
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Color(0xFF0277BD),
                                  size: 50,
                                ),
                              )
                            : GestureDetector(
                                onTap: handleImagePick,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: pickedImage!.bytes != null
                                      ? Image.memory(
                                          Uint8List.fromList(
                                              pickedImage!.bytes!), // For web
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(pickedImage!
                                              .path!), // For mobile/desktop
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            // TextFormField(
                            //   controller: _name,
                            //   decoration: const InputDecoration(
                            //     border: OutlineInputBorder(
                            //         borderSide: BorderSide.none,
                            //         borderRadius: BorderRadius.all(Radius.circular(25))),
                            //     filled: true,
                            //     fillColor: Color.fromARGB(255, 236, 236, 236),
                            //     labelText: "Name",
                            //     prefixIcon: Icon(Icons.account_circle),
                            //   ),
                            // ),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: _name,
                              decoration: InputDecoration(
                                labelText: ' Name',
                                prefixIcon: Icon(Icons.account_circle),
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blueAccent, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                fillColor: const Color(0xFF2E2E3E),
                                filled: true,
                              ),
                            ),

                            SizedBox(height: 20),

                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: _name,
                              decoration: InputDecoration(
                                labelText: ' Email',
                                prefixIcon: Icon(Icons.email_outlined),
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blueAccent, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                fillColor: const Color(0xFF2E2E3E),
                                filled: true,
                              ),
                            ),

                            // TextFormField(
                            //   controller: _email,
                            //   decoration: const InputDecoration(
                            //     border: OutlineInputBorder(
                            //         borderSide: BorderSide.none,
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(25))),
                            //     filled: true,
                            //     fillColor: Color.fromARGB(255, 236, 236, 236),
                            //     labelText: "Email",
                            //     prefixIcon: Icon(Icons.email_outlined),
                            //   ),
                            // ),

                            SizedBox(height: 20),

                            // District Dropdown
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField(
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
                                        fetchplace(
                                            newValue!); // Fetch places when district changes
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Select District",
                                      prefixIcon: Icon(Icons.location_city),
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                      filled: true,
                                      fillColor: const Color(0xFF2E2E3E),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    dropdownColor: const Color(0xFF2E2E3E),
                                    style: const TextStyle(color: Colors.white),
                                    hint: const Text(' District',
                                        style:
                                            TextStyle(color: Colors.white70)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField(
                                    items: placeList.map((place) {
                                      return DropdownMenuItem(
                                        value: place["id"].toString(),
                                        child: Text(place["place_name"]),
                                      );
                                    }).toList(),
                                    value: selectedPlace,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedPlace = newValue;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Select Place",
                                      prefixIcon: Icon(Icons.place),
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                      filled: true,
                                      fillColor: const Color(0xFF2E2E3E),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    dropdownColor: const Color(0xFF2E2E3E),
                                    style: const TextStyle(color: Colors.white),
                                    hint: const Text(' Place',
                                        style:
                                            TextStyle(color: Colors.white70)),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),

                            // TextFormField(
                            //   controller: _contact,
                            //   decoration: const InputDecoration(
                            //     border: OutlineInputBorder(
                            //         borderSide: BorderSide.none,
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(25))),
                            //     filled: true,
                            //     fillColor: Color.fromARGB(255, 236, 236, 236),
                            //     labelText: "Contact",
                            //     prefixIcon: Icon(Icons.phone_android),
                            //   ),
                            // ),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: _contact,
                              decoration: InputDecoration(
                                labelText: ' Contact',
                                prefixIcon: Icon(Icons.phone_android),
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blueAccent, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                fillColor: const Color(0xFF2E2E3E),
                                filled: true,
                              ),
                            ),

                            SizedBox(height: 20),

                            // TextFormField(
                            //   controller: _address,
                            //   decoration: const InputDecoration(
                            //     border: OutlineInputBorder(
                            //         borderSide: BorderSide.none,
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(25))),
                            //     filled: true,
                            //     fillColor: Color.fromARGB(255, 236, 236, 236),
                            //     labelText: "Address",
                            //     prefixIcon: Icon(Icons.home_rounded),
                            //   ),
                            // ),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: _address,
                              decoration: InputDecoration(
                                labelText: ' Address',
                                prefixIcon: Icon(Icons.home_rounded),
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blueAccent, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                fillColor: const Color(0xFF2E2E3E),
                                filled: true,
                              ),
                            ),

                            SizedBox(height: 20),
                            // TextFormField(
                            //   readOnly: true,
                            //   onTap: handleProofPick,
                            //   controller: _proof,
                            //   decoration: const InputDecoration(
                            //     border: OutlineInputBorder(
                            //         borderSide: BorderSide.none,
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(25))),
                            //     filled: true,
                            //     fillColor: Color.fromARGB(255, 236, 236, 236),
                            //     hintText: "Proof",
                            //     prefixIcon: Icon(Icons.document_scanner_rounded),
                            //   ),
                            // ),

                            TextFormField(
                              readOnly: true,
                              onTap: handleProofPick,
                              controller: _proof,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: ' Proof',
                                prefixIcon:
                                    Icon(Icons.document_scanner_rounded),
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blueAccent, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                fillColor: const Color(0xFF2E2E3E),
                                filled: true,
                              ),
                            ),

                            SizedBox(height: 20),
                            // TextFormField(
                            //   controller: _password,
                            //   decoration: const InputDecoration(
                            //     border: OutlineInputBorder(
                            //         borderSide: BorderSide.none,
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(25))),
                            //     filled: true,
                            //     fillColor: Color.fromARGB(255, 236, 236, 236),
                            //     labelText: "Password",
                            //     prefixIcon: Icon(Icons.lock),
                            //   ),
                            // ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    style: const TextStyle(color: Colors.white),
                                    controller: _password,
                                    decoration: InputDecoration(
                                      labelText: ' Password',
                                      prefixIcon: Icon(Icons.lock),
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      fillColor: const Color(0xFF2E2E3E),
                                      filled: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    style: const TextStyle(color: Colors.white),
                                    controller: _confirmpasswordController,
                                    decoration: InputDecoration(
                                      labelText: ' Confirm Password',
                                      prefixIcon: Icon(Icons.lock),
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade600),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      fillColor: const Color(0xFF2E2E3E),
                                      filled: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  reg();
                                },
                                child: const Text("REGISTER"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
