import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_eventticket/main.dart';
import 'package:user_eventticket/screens/homepage.dart';
import 'package:user_eventticket/screens/registration.dart';
import 'package:user_eventticket/components/form_validation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  void signin() {}
  Future<void> signIn() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final User? user = res.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
      print('SignIn Successful');
    } catch (e) {
      print('Error During SignIn: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:  Colors.white,
        title: Center(child: Text(" LOGIN")),
      ),
      body: Form(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          children: [
            SizedBox(
              height: 100,
            ),
            Image.asset(
              'assets/log1.jpeg',
              height: 200,
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _emailController,
              validator: (value) => FormValidation.validateEmail(value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: _passwordController,
              validator: (value) => FormValidation.validatePassword(value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
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
                    Color.fromARGB(255, 2, 0, 108), // Dark blue background
                foregroundColor: Colors.white, // White text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 16, horizontal: 32), // Custom padding
                elevation: 5, // Shadow effect
                shadowColor: Colors.black.withOpacity(0.3), // Soft shadow color
                textStyle: TextStyle(
                  fontSize: 16, // Text size
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
              child: const Text("LOG IN"),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationPage(),
                        ));

                    // Navigate to sign-in screen
                  },
                  child: const Text("Register",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
