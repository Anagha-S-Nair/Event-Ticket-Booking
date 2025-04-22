import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StallChangePassword extends StatefulWidget {
  const StallChangePassword({super.key});

  @override
  State<StallChangePassword> createState() => _StallChangePasswordState();
}

class _StallChangePasswordState extends State<StallChangePassword> {
  bool currentPassVisible = false;
  bool newPassVisible = false;
  bool confirmPassVisible = false;

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String oldPassword = "";

  @override
  void initState() {
    super.initState();
    fetchCurrentPassword();
  }

  Future<void> fetchCurrentPassword() async {
    try {
      String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final response = await Supabase.instance.client
            .from('tbl_stallmanager')
            .select('stallmanager_password')
            .eq('id', userId)
            .single();
        setState(() {
          oldPassword = response['stallmanager_password'];
        });
      }
    } catch (e) {
      print("Error fetching current password: $e");
    }
  }

  Future<void> updatePassword() async {
    try {
      String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      if (currentPasswordController.text != oldPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Current password is incorrect!")),
        );
        return;
      }

      if (newPasswordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("New passwords do not match!")),
        );
        return;
      }

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPasswordController.text),
      );

      await Supabase.instance.client
          .from('tbl_stallmanager')
          .update({'stallmanager_password': newPasswordController.text})
          .eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password updated successfully!")),
      );
    } catch (e) {
      print("Error updating password: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Container(
            height: 400,
            width: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Change Password",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  _passwordField(
                    "Current Password",
                    currentPasswordController,
                    currentPassVisible,
                    () => setState(() => currentPassVisible = !currentPassVisible),
                    (value) {
                      if (value == null || value.isEmpty) return "Enter current password";
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _passwordField(
                    "New Password",
                    newPasswordController,
                    newPassVisible,
                    () => setState(() => newPassVisible = !newPassVisible),
                    (value) {
                      if (value == null || value.isEmpty) return "Enter new password";
                      if (value.length < 6) return "Password must be at least 6 characters";
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _passwordField(
                    "Confirm Password",
                    confirmPasswordController,
                    confirmPassVisible,
                    () => setState(() => confirmPassVisible = !confirmPassVisible),
                    (value) {
                      if (value == null || value.isEmpty) return "Confirm your password";
                      if (value != newPasswordController.text) return "Passwords do not match";
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          updatePassword();
                        }
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField(
    String hintText,
    TextEditingController controller,
    bool obscureText,
    VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: UnderlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
