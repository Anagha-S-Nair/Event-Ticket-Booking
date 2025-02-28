import 'package:admin_eventticket/main.dart';
import 'package:admin_eventticket/screens/homepage.dart';
import 'package:flutter/material.dart';
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));
      print("SignIn Successfull");
    } catch (e) {
      print("Error During SignIn: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 400,
              height: 500,
              margin: EdgeInsets.only(top: 50), // To adjust for CircleAvatar
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 48, 48, 48).withOpacity(0.7),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.all(50),
                children: [
                  TextFormField(
                    controller: _emailController,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: const Color.fromARGB(255, 202, 202, 202),
                      ),
                      hintText: "Enter Email Address",
                      labelText: "Email ",
                      labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 198, 198, 198),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: const Color.fromARGB(255, 204, 204, 204),
                      ),
                      suffixIcon: Icon(
                        Icons.visibility,
                        color: const Color.fromARGB(255, 204, 204, 204),
                      ),
                      hintText: "Please Enter Password",
                      labelText: "Password",
                      labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 196, 196, 196),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      signIn();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 179, 7, 227),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "LOGIN",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 236, 235, 235),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // CircleAvatar positioned to overlap the container
            CircleAvatar(
              radius: 50,
              // backgroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              child: Container(
                width: 70,
                height: 100,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF8A2BE2), // Blue-violet
                      Color(0xFFDA70D6), // Orchid
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              child: Icon(
                Icons.lock,
                size: 50,
                color: Colors.blue,
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
