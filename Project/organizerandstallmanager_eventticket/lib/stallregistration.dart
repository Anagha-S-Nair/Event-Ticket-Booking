import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:file_picker/file_picker.dart';

class Stallregistration extends StatefulWidget {
  const Stallregistration({super.key});

  @override
  State<Stallregistration> createState() => _StallregistrationState();
}

class _StallregistrationState extends State<Stallregistration> {
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
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<void> handleProofPick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
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
      final bucketName = 'organisers';
      final filePath = "$uid-photo-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!,
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<String?> proofUpload(String uid) async {
    try {
      final bucketName = 'organisers';
      final filePath = "$uid-proof-${pickedProof!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedProof!.bytes!,
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
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
        selectedPlace = null;
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
      await supabase.from("tbl_stallmanager").insert({
        'id': uid,
        'stallmanager_name': _name.text,
        'stallmanager_email': _email.text,
        'stallmanager_address': _address.text,
        'stallmanager_password': _password.text,
        'stallmanager_contact': _contact.text,
        'place_id': selectedPlace,
        'stallmanager_photo': photoUrl,
        'stallmanager_proof': proofUrl,
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
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: SizedBox(
            width: 600,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Text(
                          "Register as Stall Manager",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Fill in the details below to get started.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 32),

                      // Profile Image Upload
                      Center(
                        child: GestureDetector(
                          onTap: handleImagePick,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[100],
                            child: pickedImage == null
                                ? Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Color.fromARGB(255, 19, 37, 82),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: pickedImage!.bytes != null
                                        ? Image.memory(
                                            Uint8List.fromList(
                                                pickedImage!.bytes!),
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                          )
                                        : Image.file(
                                            File(pickedImage!.path!),
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                          ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Name Field
                      TextFormField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.person,
                              color: Color.fromARGB(255, 19, 37, 82)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 19, 37, 82)!,
                                width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Enter your name";
                          }
                          if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                            return "Name can only contain letters";
                          }
                          if (!RegExp(r"^[A-Z]").hasMatch(value.trim())) {
                            return "First letter must be capital";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          prefixIcon: Icon(Icons.email,
                              color: Color.fromARGB(255, 19, 37, 82)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 19, 37, 82)!,
                                width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Enter your email";
                          }
                          if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                              .hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // District and Place Dropdowns
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField(
                              value: selectedDistrict,
                              items: districtList.map((district) {
                                return DropdownMenuItem(
                                  value: district["id"].toString(),
                                  child: Text(district["district_name"]),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedDistrict = newValue;
                                  fetchplace(newValue!);
                                });
                              },
                              decoration: InputDecoration(
                                labelText: "District",
                                prefixIcon: Icon(Icons.location_city,
                                    color: Color.fromARGB(255, 19, 37, 82)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          const Color.fromARGB(255, 19, 37, 82)!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) =>
                                  value == null ? "Select a district" : null,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField(
                              value: selectedPlace,
                              items: placeList.map((place) {
                                return DropdownMenuItem(
                                  value: place["id"].toString(),
                                  child: Text(place["place_name"]),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedPlace = newValue;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: "Place",
                                prefixIcon: Icon(Icons.place,
                                    color: Color.fromARGB(255, 19, 37, 82)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          const Color.fromARGB(255, 19, 37, 82)!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) =>
                                  value == null ? "Select a place" : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Contact Field
                      TextFormField(
                        controller: _contact,
                        decoration: InputDecoration(
                          labelText: "Contact Number",
                          prefixIcon: Icon(Icons.phone,
                              color: Color.fromARGB(255, 19, 37, 82)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 19, 37, 82)!,
                                width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Enter your contact";
                          }
                          if (!RegExp(r"^\d{10}$").hasMatch(value)) {
                            return "Enter a valid 10-digit number";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Address Field
                      TextFormField(
                        controller: _address,
                        decoration: InputDecoration(
                          labelText: "Address",
                          prefixIcon: Icon(Icons.home,
                              color: Color.fromARGB(255, 19, 37, 82)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 19, 37, 82)!,
                                width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Enter your address"
                                : null,
                      ),
                      SizedBox(height: 16),

                      // Proof Upload
                      TextFormField(
                        readOnly: true,
                        controller: _proof,
                        onTap: handleProofPick,
                        decoration: InputDecoration(
                          labelText: "Upload Proof",
                          prefixIcon: Icon(Icons.upload_file,
                              color: Color.fromARGB(255, 19, 37, 82)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 19, 37, 82)!,
                                width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Upload a proof"
                                : null,
                      ),
                      SizedBox(height: 16),

                      // Password Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _password,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock,
                                    color: Color.fromARGB(255, 19, 37, 82)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          const Color.fromARGB(255, 19, 37, 82)!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter a password";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _confirmpasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Confirm Password",
                                prefixIcon: Icon(Icons.lock,
                                    color: Color.fromARGB(255, 19, 37, 82)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          const Color.fromARGB(255, 19, 37, 82)!,
                                      width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) => value != _password.text
                                  ? "Passwords do not match"
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: reg,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color.fromARGB(255, 19, 37, 82),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            "REGISTER",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}