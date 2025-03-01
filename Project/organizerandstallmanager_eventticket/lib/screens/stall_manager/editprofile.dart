import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';

class StallEditProfile extends StatefulWidget {
  const StallEditProfile({super.key});

  @override
  State<StallEditProfile> createState() => _StallEditProfileState();
}

class _StallEditProfileState extends State<StallEditProfile> {
  Map<String, dynamic> data = {};
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

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
      final response = await supabase
          .from('tbl_stallmanager')
          .select()
          .eq('id', uid)
          .single();

      setState(() {
        data = response;
        nameController.text = data['stallmanager_name'];
        emailController.text = data['stallmanager_email'];
        contactController.text = data['stallmanager_contact'];
        profileImageUrl = data['stallmanager_photo']; // Fetch stored profile image
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Restrict to images
      allowMultiple: false,
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
      
      final publicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("Error uploading photo: $e");
      return null;
    }
  }

  Future<void> updateUser() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      String? newPhotoUrl = await photoUpload(uid); // Upload new image if available

      await supabase.from('tbl_stallmanager').update({
        'stallmanager_name': nameController.text,
        'stallmanager_email': emailController.text,
        'stallmanager_contact': contactController.text,
        if (newPhotoUrl != null) 'stallmanager_photo': newPhotoUrl, // Update image if changed
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
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Container(
                height: 500,
                width: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _profileField(Icons.person, nameController),
                              SizedBox(height: 30),
                              _profileField(Icons.email, emailController),
                              SizedBox(height: 30),
                              _profileField(Icons.phone, contactController),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                        SizedBox(width: 50),
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 100,
                                  backgroundImage: pickedImage != null
                                      ? (pickedImage!.bytes != null
                                          ? MemoryImage(Uint8List.fromList(pickedImage!.bytes!)) as ImageProvider
                                          : FileImage(File(pickedImage!.path!)) as ImageProvider)
                                      : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                                          ? NetworkImage(profileImageUrl!)
                                          : null),
                                  child: pickedImage == null && (profileImageUrl == null || profileImageUrl!.isEmpty)
                                      ? Icon(Icons.image_outlined, color: Color(0xFF0277BD), size: 50)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 15,
                                  right: 15,
                                  child: GestureDetector(
                                    onTap: handleImagePick,
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.edit, color: Colors.blue, size: 24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 580,
            left: 950,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                backgroundColor: Colors.pinkAccent,
              ),
              onPressed: updateUser,
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileField(IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 24),
          SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(border: UnderlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }
}
