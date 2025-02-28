import 'package:flutter/material.dart';

class StallProfile extends StatelessWidget {
  const StallProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF212121), Color(0xFF424242), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Container(
                height: 520,
                width: 600,
                decoration: BoxDecoration(
                  color: Color(0xFF2C2C2C).withOpacity(0.95), // Dark slate grey with slight transparency
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(25),
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
                              _profileField(Icons.person, "Jane Walters"),
                              SizedBox(height: 25),
                              _profileField(Icons.email, "j.walters@domain.com"),
                              SizedBox(height: 25),
                              _profileField(Icons.lock, "••••••••"),
                              SizedBox(height: 25),
                              _profileField(Icons.phone, "+1 012 345 678"),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                        SizedBox(width: 40),
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[700],
                                  backgroundImage: NetworkImage(
                                    "https://your-image-url.com", // Replace with actual image URL
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.grey.shade400,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.redAccent,
                          elevation: 5,
                          shadowColor: Colors.red.withOpacity(0.3),
                        ),
                        onPressed: () {},
                        child: Text(
                          "Save",
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
            color: Colors.grey.shade300,
            size: 26,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade500,
                    width: 1.5,
                  ),
                ),
              ),
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
