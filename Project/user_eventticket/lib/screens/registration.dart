import 'package:flutter/material.dart';
import 'package:user_eventticket/components/form_validation.dart';
import 'package:user_eventticket/main.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  List<Map<String, dynamic>> registartionList = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  Future<void> register() async {
    try {
      final authentication = await supabase.auth.signUp(
          password: _passwordController.text, email: _emailController.text);
      String uid = authentication.user!.id;
      insertUser(uid);
    } catch (e) {
      print("Error Registration: $e");
    }
  }

  Future<void> insertUser(String uid) async {
    try {
      String name = _nameController.text;
      String email = _emailController.text;
      String contact = _contactController.text;
      String address = _addressController.text;
      String password = _passwordController.text;

      await supabase.from('tbl_user').insert({
        'id': uid,
        'user_name': name,
        'user_email': email,
        'user_contact': contact,
        'user_address': address,
        'user_password': password,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Successfully Registered",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      _emailController.clear();
      _contactController.clear();
      _addressController.clear();
      _passwordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR ADDING REGISTRATION: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 50,
              left: 280,
              child: Container(
                height: 60,
                width: 60,
                decoration:
                    BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              top: 80,
              left: 50,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 19, 33, 111),
                    shape: BoxShape.circle),
              ),
            ),
            Positioned(
              top: 150,
              left: 30,
              child: Container(
                height: 800,
                width: 800,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 19, 33, 111),
                    shape: BoxShape.circle),
              ),
            ),
            SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                    ),
                    Container(
                      // child: Icon(Icons.person_2_outlined, size: 100,),
        
                      height: 170,
                      width: 170,
                      decoration: BoxDecoration(
                        color: Colors.pink[300],
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/bg3.png',
                        width: 300, // Set desired width
                        height: 300, // Set desired height
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Text("Registration",),
                    Padding(
                      padding: const EdgeInsets.only(left: 100.0, top: 40),
                      child: Column(
                        children: [
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: _nameController,
                            validator: (value) =>
                                FormValidation.validateName(value),
                            decoration: const InputDecoration(
                                labelText: "Name",
                                prefixIcon: Icon(Icons.account_circle),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.pink)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 112, 36, 61),
                                        width: 2))),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: _emailController,
                            validator: (value) =>
                                FormValidation.validateEmail(value),
                            decoration: const InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email_outlined),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.pink,
                                )),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 112, 36, 61),
                                        width: 2))),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: _addressController,
                            validator: (value) =>
                                FormValidation.validateAddress(value),
                            decoration: const InputDecoration(
                                labelText: "Address",
                                prefixIcon: Icon(Icons.home),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.pink,
                                )),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 112, 36, 61),
                                        width: 2))),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: _contactController,
                            validator: (value) =>
                                FormValidation.validateContact(value),
                            decoration: const InputDecoration(
                                labelText: "Contact",
                                prefixIcon: Icon(Icons.phone_android_rounded),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.pink,
                                )),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 112, 36, 61),
                                        width: 2))),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: _passwordController,
                            validator: (value) =>
                                FormValidation.validatePassword(value),
                            decoration: const InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.pink)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 112, 36, 61),
                                        width: 2))),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: _confirmpasswordController,
                            //  validator: (value) => FormValidation.validateConfirmPassword(value),
                            decoration: const InputDecoration(
                                labelText: "Confirm Password",
                                prefixIcon: Icon(Icons.lock_reset_outlined),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.pink)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 112, 36, 61),
                                        width: 2))),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink),
                          onPressed: () {
                            if (formkey.currentState!.validate()) {
                              register();
                            }
                          },
                          child: const Text(
                            "REGISTER",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
