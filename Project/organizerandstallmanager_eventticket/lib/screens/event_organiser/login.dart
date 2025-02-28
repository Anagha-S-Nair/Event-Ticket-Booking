import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage2 extends StatefulWidget {
  const LoginPage2({super.key});

  @override
  State<LoginPage2> createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;
      print("email");
      print("password");
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrganiserHomePage(),
        ),
      );
      print("SignIn Successfull");
    } catch (e) {
      print("Error During SignIn: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [
        //       Colors.blueAccent,
        //       Colors.purpleAccent,
        //       Colors.pinkAccent,
        //     ],
        //   ),
        // ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/l12.jpg'), // Make sure the image is in your assets folder
            fit: BoxFit.cover, // This makes the image cover the entire screen
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        // Colors.blueAccent,
                        const Color.fromARGB(204, 255, 43, 198),
                        const Color.fromARGB(255, 115, 34, 61),
                      ],
                    ),

                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 48, 48, 48)
                            .withOpacity(0.7),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  width: 500,
                  height: 350,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 40), // Space for the avatar
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          labelText: "Email ID",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          signIn();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 11, 78, 195),
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 80,
                          ),
                        ),
                        child: Text(
                          "LOGIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18, // Increased font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -30, // Moves the CircleAvatar to touch the container
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color.fromARGB(255, 78, 106, 154),
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
