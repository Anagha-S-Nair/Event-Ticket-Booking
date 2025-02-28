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
      final response = await supabase.from('tbl_eventorganisers').select().eq('id', uid).single();
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
                              _profileField(Icons.person, data['organisers_name']),
                              SizedBox(height: 30),
                              _profileField(Icons.email, data['organisers_email']),
                              SizedBox(height: 30),
                              // _profileField(Icons.lock, "••••••••"),
                              // SizedBox(height: 30),
                              _profileField(Icons.phone, data['organisers_contact']),
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
                                  backgroundImage: NetworkImage(
                                    data['organiser_photo'], // Replace with actual image URL
                                  ),
                                ),
                                Positioned(
                                  bottom: 15,
                                  right: 15,
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 100,
                          height: 200,
                        )
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 580,
            left: 300,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: Colors.pinkAccent,
              ),
              onPressed: () {
                 Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrganiserPassword(),
                              ));

              },
              child: Text(
                "Change Password",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: Colors.pinkAccent,
              ),
              onPressed: () {
                 Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfile(),
                              ));

              },
              child: Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileField(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[700],
            size: 24,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
              ),
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
