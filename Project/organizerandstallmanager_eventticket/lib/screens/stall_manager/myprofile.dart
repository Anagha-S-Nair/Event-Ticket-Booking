import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:organizerandstallmanager_eventticket/screens/stall_manager/changepassword.dart';
import 'package:organizerandstallmanager_eventticket/screens/stall_manager/editprofile.dart';

class StallProfile extends StatefulWidget {
  const StallProfile({super.key});

  @override
  State<StallProfile> createState() => _StallProfileState();
}

class _StallProfileState extends State<StallProfile> {
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
      final response = await supabase
          .from('tbl_stallmanager')
          .select("*,tbl_place(*)")
          .eq('id', uid)
          .single();
      setState(() {
        data = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: Container(
                  width: 800,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Profile Details",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _profileField(Icons.person, "Name", data['stallmanager_name']),
                            const SizedBox(height: 20),
                            _profileField(Icons.email, "Email", data['stallmanager_email']),
                            const SizedBox(height: 20),
                            _profileField(Icons.phone, "Contact", data['stallmanager_contact']),
                            const SizedBox(height: 20),
                            _profileField(Icons.home, "Address", 
                                data['stallmanager_address'] ?? 'No address provided'),
                            const SizedBox(height: 20),
                            _profileField(Icons.place, "Place", 
                                data['tbl_place']?['place_name'] ?? 'No place provided'),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _actionButton(
                                  context: context,
                                  label: "Edit Profile",
                                  color: Colors.blueAccent,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => StallEditProfile()),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                _actionButton(
                                  context: context,
                                  label: "Change Password",
                                  color: Colors.deepPurple,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => StallChangePassword()),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(data['stallmanager_photo'] ?? ''),
                        backgroundColor: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileField(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.deepPurple, size: 24),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 400,
              child: Text(
                value ?? 'Not provided',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 3,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}