import 'package:flutter/material.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("My Profile",style: TextStyle(fontWeight: FontWeight.bold),))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/Profileicon2.png'), 
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child:
                          Icon(Icons.edit, size: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            buildTextField("Full Name",icon: Icons.person),
            buildTextField("Email", icon: Icons.email_outlined),
            buildTextField("Contact", icon: Icons.phone_android),
            buildTextField("Address", icon: Icons.home),
            buildTextField("Location", icon: Icons.location_on),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 234, 146, 88),
                  minimumSize: Size(double.infinity, 50)),
              child:
                  Text("SAVE CHANGES", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
