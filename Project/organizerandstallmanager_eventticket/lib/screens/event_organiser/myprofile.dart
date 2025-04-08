import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/changepassword.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/editprofile.dart';

class OrganiserProfile extends StatefulWidget {
  const OrganiserProfile({super.key});

  @override
  State<OrganiserProfile> createState() => _OrganiserProfileState();
}

class _OrganiserProfileState extends State<OrganiserProfile> {
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
          .from('tbl_eventorganisers')
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
              // Profile Details Section with Photo on the Right
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
                      // Profile Details Column
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
                            _profileField(Icons.person, "Name", data['organisers_name']),
                            const SizedBox(height: 20),
                            _profileField(Icons.email, "Email", data['organisers_email']),
                            const SizedBox(height: 20),
                            _profileField(Icons.phone, "Contact", data['organisers_contact']),
                            const SizedBox(height: 20),
                            _profileField(Icons.home, "Address", 
                                data['organisers_address'] ?? 'No address provided'),
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
                                    MaterialPageRoute(builder: (context) => EditProfile()),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                _actionButton(
                                  context: context,
                                  label: "Change Password",
                                  color: Colors.deepPurple,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => OrganiserPassword()),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      // Profile Photo
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(data['organiser_photo'] ?? ''),
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
              width: 400, // Adjusted width to fit beside the photo
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