import 'dart:io';

import 'package:flutter/material.dart';
import 'package:user_eventticket/main.dart';
import 'package:file_picker/file_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Map<String, dynamic> data = {};
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  PlatformFile? pickedImage;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response =
          await supabase.from('tbl_user').select().eq('id', uid).single();

      setState(() {
        data = response;
        nameController.text = data['user_name'] ?? '';

        contactController.text = data['user_contact'] ?? '';
        addressController.text = data['user_address'] ?? '';
        locationController.text = data['location'] ?? '';
        profileImageUrl = data['user_photo']; // Fetch stored profile image
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // Ensures `pickedImage!.bytes` is populated
    );

    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<String?> photoUpload(String uid) async {
    if (pickedImage == null) return null; // If no new image selected, return

    try {
      final bucketName = 'organisers';
      final filePath = "$uid-event-${pickedImage!.name}";

      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!,
          );

      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("Error uploading photo: $e");
      return null;
    }
  }

  Future<void> updateUser() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      String? newPhotoUrl =
          await photoUpload(uid); // Upload new image if available

      await supabase.from('tbl_user').update({
        'user_name': nameController.text,

        'user_contact': contactController.text,
        'user_address': addressController.text,

        if (newPhotoUrl != null)
          'user_photo': newPhotoUrl, // Update image if changed
      }).eq('id', uid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );

      fetchUser(); // Refresh UI after update
    } catch (e) {
      print("Error updating user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
              child: Text(
            "Edit Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: pickedImage != null
                                ? FileImage(File(pickedImage!
                                    .path!)) // Correctly loads from file
                                : (profileImageUrl != null &&
                                            profileImageUrl!.isNotEmpty
                                        ? NetworkImage(profileImageUrl!)
                                        : const AssetImage(
                                            'assets/Profileicon2.png'))
                                    as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: handleImagePick,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.edit,
                                    size: 18, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    buildEditableField(
                        Icons.person, "Full Name", nameController),
                    buildEditableField(
                        Icons.phone_android, "Contact", contactController),
                    buildEditableField(
                        Icons.home, "Address", addressController),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: updateUser,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 234, 146, 88),
                          minimumSize: Size(double.infinity, 50)),
                      child: Text("SAVE CHANGES",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildEditableField(
      IconData icon, String label, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
