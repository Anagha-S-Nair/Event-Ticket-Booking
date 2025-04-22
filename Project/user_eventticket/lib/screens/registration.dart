import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:user_eventticket/components/form_validation.dart';
import 'package:user_eventticket/main.dart';
import 'package:user_eventticket/screens/login.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();

  final formkey = GlobalKey<FormState>();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    try {
      if (_image == null) return null;

      String formattedDate = DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      String fileExtension = path.extension(_image!.path);
      String fileName = 'organisers-$formattedDate$fileExtension';

      await supabase.storage.from('organisers').upload(fileName, _image!);
      return supabase.storage.from('organisers').getPublicUrl(fileName);
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> register() async {
    if (!formkey.currentState!.validate()) {
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a profile image.")),
      );
      return;
    }
    try {
      String? imageUrl = await _uploadImage();
      print('Image URL: $imageUrl'); // Debug print

      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload failed. Please try again.")),
        );
        return;
      }

      final authentication = await supabase.auth.signUp(
        password: _passwordController.text,
        email: _emailController.text,
      );

      String uid = authentication.user!.id;
      await insertUser(uid, imageUrl); // Await here for safety
    } catch (e) {
      print("Error registration: $e");
    }
  }

  Future<void> insertUser(String uid, String? imageUrl) async {
    try {
      print('Inserting user with photo: $imageUrl'); // Debug print
      await supabase.from('tbl_user').insert({
        'id': uid,
        'user_name': _nameController.text,
        'user_email': _emailController.text,
        'user_contact': _contactController.text,
        'user_password': _passwordController.text,
        'user_photo': imageUrl, // This should be a string URL
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("REGISTERED SUCCESSFULLY", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      _nameController.clear();
      _emailController.clear();
      _contactController.clear();
      _passwordController.clear();
      _confirmpasswordController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed. Please Try Again!!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      print("ERROR REGISTERING: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light grey background for modern UI
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text("REGISTRATION", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Form(
        key: formkey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.white,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(Icons.add_a_photo, color: Colors.grey.shade700, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, "Name", Icons.account_circle),
              _buildTextField(_emailController, "Email", Icons.email_outlined),
              _buildTextField(_contactController, "Contact", Icons.phone),
              _buildPasswordField(_passwordController, "Password", _isPasswordVisible, () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              }),
              _buildPasswordField(_confirmpasswordController, "Confirm Password", _isConfirmPasswordVisible, () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              }),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 0, 108),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('REGISTER', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color.fromARGB(255, 2, 0, 108), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color.fromARGB(255, 2, 0, 108), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color.fromARGB(255, 2, 0, 108), width: 1),
          ),
          labelText: label,
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 2, 0, 108)),
        ),
        validator: (value) {
          if (label == "Email") {
            if (value == null || value.trim().isEmpty) return "Please enter your email";
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter a valid email";
          } else if (label == "Contact") {
            if (value == null || value.trim().isEmpty) return "Please enter your contact";
            if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) return "Enter a valid contact number";
          } else if (label == "Name") {
            if (value == null || value.trim().isEmpty) return "Please enter your name";
          } 
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool isVisible, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        obscureText: !isVisible,
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color.fromARGB(255, 2, 0, 108), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color.fromARGB(255, 2, 0, 108), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color.fromARGB(255, 2, 0, 108), width: 1),
          ),
          labelText: label,
          prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 2, 0, 108)),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
            onPressed: toggleVisibility,
          ),
        ),
        validator: (value) {
          if (label == "Password") {
            if (value == null || value.isEmpty) return "Please enter a password";
            if (value.length < 6) return "Password must be at least 6 characters";
          } else if (label == "Confirm Password") {
            if (value == null || value.isEmpty) return "Please confirm your password";
            if (value != _passwordController.text) return "Passwords do not match";
          }
          return null;
        },
      ),
    );
  }
}