import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/homepage.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:organizerandstallmanager_eventticket/organsierRegistration.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/homepage.dart';
import 'package:organizerandstallmanager_eventticket/screens/stall_manager/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final org = await supabase
          .from('tbl_eventorganisers')
          .select('id')
          .eq('id', res.user!.id);
      final stall = await supabase
          .from('tbl_stallmanager')
          .select('id')
          .eq('id', res.user!.id);
      if (org.isNotEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrganiserHomePage(),
            ));
      } else if (stall.isNotEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StallHomePage(),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid Email or Password"),
          duration: Duration(seconds: 2),
        ));
        print("Error: UID Not found on both Organiser and Stall Manager");
      }
    } catch (e) {
      print("Error During SignIn: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF1E1E2E),
            ),
          ),
          Center(
            child: Container(
              width: 500,
              height: 350, // Increased height to accommodate the avatar
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2E2E3E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circle Avatar with Login Icon
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFF0277BD),
                    child: Icon(Icons.lock, color: Colors.white, size: 45),
                  ),
                  SizedBox(height: 20),
                  // Email Field
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email ID',
                      prefixIcon: Icon(Icons.email, color: Colors.white70),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: Color(0xFF3A3A4A),
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 25),
                  // Password Field
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.white70),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: Color(0xFF3A3A4A),
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 25),
                  // Login Button
                  ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0277BD),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                    ),
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
