import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Map<String, dynamic> data = {};
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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
          .from('tbl_eventorganisers')
          .select()
          .eq('id', uid)
          .single();

      setState(() {
        data = response;
        nameController.text = data['organisers_name'];
        emailController.text = data['organisers_email'];
        contactController.text = data['organisers_contact'];
        addressController.text = data['organisers_address'] ?? '';
        profileImageUrl = data['organiser_photo'];
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
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<String?> photoUpload(String uid) async {
    if (pickedImage == null) return null;

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
      String? newPhotoUrl = await photoUpload(uid);

      await supabase.from('tbl_eventorganisers').update({
        'organisers_name': nameController.text,
        'organisers_email': emailController.text,
        'organisers_contact': contactController.text,
        'organisers_address': addressController.text,
        if (newPhotoUrl != null) 'organiser_photo': newPhotoUrl,
      }).eq('id', uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );

      fetchUser();
    } catch (e) {
      print("Error updating user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Container(
            height: 600,
            width: 600,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _profileField(Icons.person, nameController),
                          const SizedBox(height: 30),
                          _profileField(Icons.email, emailController),
                          const SizedBox(height: 30),
                          _profileField(Icons.phone, contactController),
                          const SizedBox(height: 30),
                          _profileField(Icons.home, addressController),
                        ],
                      ),
                    ),
                    const SizedBox(width: 50),
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 100,
                              backgroundImage: pickedImage != null
                                  ? (pickedImage!.bytes != null
                                      ? MemoryImage(
                                              Uint8List.fromList(
                                                  pickedImage!.bytes!))
                                          as ImageProvider
                                      : FileImage(File(pickedImage!.path!))
                                          as ImageProvider)
                                  : (profileImageUrl != null &&
                                          profileImageUrl!.isNotEmpty
                                      ? NetworkImage(profileImageUrl!)
                                      : null),
                              child: pickedImage == null &&
                                      (profileImageUrl == null ||
                                          profileImageUrl!.isEmpty)
                                  ? const Icon(Icons.image_outlined,
                                      color: Color(0xFF0277BD), size: 50)
                                  : null,
                            ),
                            Positioned(
                              bottom: 15,
                              right: 15,
                              child: GestureDetector(
                                onTap: handleImagePick,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.blue, size: 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Save Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shadowColor: Colors.deepPurple.withOpacity(0.4),
                    ),
                    onPressed: updateUser,
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileField(IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
