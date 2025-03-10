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
  List<Map<String, dynamic>> registrationList = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  final formkey = GlobalKey<FormState>();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Add boolean variables for password visibility
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
      if (_image == null) return null; // Check if an image is selected

      String formattedDate =
          DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      String fileExtension = path.extension(_image!.path);
      String fileName = 'organisers-$formattedDate$fileExtension';

      await supabase.storage.from('organisers').upload(fileName, _image!);
      final imageUrl =
          supabase.storage.from('organisers').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> register() async {
    try {
      // Upload image first
      String? imageUrl = await _uploadImage();

      final authentication = await supabase.auth.signUp(
        password: _passwordController.text,
        email: _emailController.text,
      );

      String uid = authentication.user!.id;
      insertUser(uid, imageUrl);
    } catch (e) {
      print("Error registration: $e");
    }
  }

  Future<void> insertUser(String uid, String? imageUrl) async {
    try {
      String name = _nameController.text;
      String email = _emailController.text;
      String contact = _contactController.text;
      String password = _passwordController.text;
      String address = _addressController.text;

      await supabase.from('tbl_user').insert({
        'id': uid,
        'user_name': name,
        'user_email': email,
        'user_contact': contact,
        'user_password': password,
        'user_address': address, // Address now properly inserted
        'user_photo': imageUrl, // Store the image URL correctly
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "REGISTERED SUCCESSFULLY",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));

      _nameController.clear();
      _emailController.clear();
      _contactController.clear();
      _passwordController.clear();
      _confirmpasswordController.clear();
      _addressController.clear();
      setState(() {
        _image = null; // Clear selected image after successful registration
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR REGISTERING: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(child: Text(" REGISTRATION")),
      ),
      body: Form(
        key: formkey,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(
                        Icons.add_a_photo,
                        color: Color.fromARGB(255, 58, 58, 58),
                        size: 50,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              validator: (value) => FormValidation.validateName(value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Name",
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            TextFormField(
              controller: _addressController,
              validator: (value) => FormValidation.validateAddress(value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Address",
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _contactController,
              validator: (value) => FormValidation.validateContact(value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Contact",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              obscureText: !_isPasswordVisible,  // Toggle visibility using the variable
              controller: _passwordController,
              validator: (value) => FormValidation.validatePassword(value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    // color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // Toggle the visibility
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              obscureText: !_isConfirmPasswordVisible,  // Toggle visibility for confirm password
              controller: _confirmpasswordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Confirm Password",
                prefixIcon: Icon(Icons.lock_reset),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    // color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible; // Toggle the visibility
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: register,
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
              child: Text('REGISTER'),
            ),
            SizedBox(height: 20), // Add some space between the button and the text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                    // Add your navigation logic here to the Sign In page
                    // For example, Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
