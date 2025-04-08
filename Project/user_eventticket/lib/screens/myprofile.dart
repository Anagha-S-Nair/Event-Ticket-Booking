import 'package:flutter/material.dart';
import 'package:user_eventticket/main.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  Map<String, dynamic> data = {};
  bool isLoading = true;

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
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                Center(
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: data["user_photo"] == null ||
                            data["user_photo"].isEmpty
                        ? const AssetImage('assets/Profileicon2.png')
                            as ImageProvider
                        : NetworkImage(data["user_photo"]),
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Information Boxes
                buildProfileBox(Icons.person, "Full Name", data["user_name"]),
                buildProfileBox(Icons.email_outlined, "Email", data["user_email"]),
                buildProfileBox(Icons.phone_android, "Contact", data["user_contact"]),
                buildProfileBox(Icons.home, "Address", data["user_address"]),
              ],
            ),
    );
  }

  Widget buildProfileBox(IconData icon, String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 2, 0, 108), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value != null && value.isNotEmpty ? value : "Not available",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
