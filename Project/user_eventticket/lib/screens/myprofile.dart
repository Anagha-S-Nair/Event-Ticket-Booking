import 'package:flutter/material.dart';
import 'package:user_eventticket/main.dart';
import 'package:user_eventticket/screens/changepassword.dart';
import 'package:user_eventticket/screens/editprofile.dart';
import 'package:user_eventticket/screens/mycomplaints.dart';

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
    return  Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: data["user_photo"] == "" ? AssetImage('assets/Profileicon2.png') as ImageProvider : NetworkImage(data["user_photo"]),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.edit, size: 18, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  buildProfileBox(Icons.person, data["user_name"] ?? ""),
                  buildProfileBox(Icons.email_outlined, data["user_email"] ?? ""),
                  buildProfileBox(Icons.phone_android, data["user_contact"] ?? ""),
                  buildProfileBox(Icons.home, data["user_address"] ?? ""),
                  buildProfileBox(Icons.location_on, data["location"] ?? ""),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 234, 146, 88),
                        minimumSize: Size(double.infinity, 50)),
                    child: Text("EDIT PROFILE", style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePassword(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 21, 96, 236),
                        minimumSize: Size(double.infinity, 50)),
                    child: Text("CHANGE PASSWORD",
                        style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyComplaintsPage(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 234, 146, 88),
                        minimumSize: Size(double.infinity, 50)),
                    child: Text("MY COMPLAINTS",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
    );
  }

  Widget buildProfileBox(IconData icon, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
            child: Text(
              value.isNotEmpty ? value : "Not available",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
