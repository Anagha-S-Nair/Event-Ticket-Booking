import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganiserPassword extends StatefulWidget {
  const OrganiserPassword({super.key});

  @override
  State<OrganiserPassword> createState() => _OrganiserPasswordState();
}

class _OrganiserPasswordState extends State<OrganiserPassword> {
  bool currentPassVisible = false;
  bool newPassVisible = false;
  bool confirmPassVisible = false;

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

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
            .from('tbl_eventorganisers')
            .select('organisers_password')
            .eq('id', userId)
            .single();
        setState(() {
          oldPassword = response['organisers_password'];
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
          const SnackBar(content: Text("Current password is incorrect!")),
        );
        return;
      }

      if (newPasswordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New passwords do not match!")),
        );
        return;
      }

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPasswordController.text),
      );

      await Supabase.instance.client
          .from('tbl_eventorganisers')
          .update({'organisers_password': newPasswordController.text})
          .eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully!")),
      );
    } catch (e) {
      print("Error updating password: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Container(
            height: 500,
            width: 600,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _passwordField("Current Password", currentPasswordController,
                    currentPassVisible, () {
                  setState(() => currentPassVisible = !currentPassVisible);
                }),
                const SizedBox(height: 20),
                _passwordField("New Password", newPasswordController,
                    newPassVisible, () {
                  setState(() => newPassVisible = !newPassVisible);
                }),
                const SizedBox(height: 20),
                _passwordField("Confirm Password", confirmPasswordController,
                    confirmPassVisible, () {
                  setState(() => confirmPassVisible = !confirmPassVisible);
                }),
                const SizedBox(height: 30),

                // Save Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shadowColor: Colors.deepPurple.withOpacity(0.4),
                    ),
                    onPressed: updatePassword,
                    child: const Text(
                      "Save",
                      style: TextStyle(
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
    );
  }

  Widget _passwordField(String hintText, TextEditingController controller,
      bool obscureText, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: const TextStyle(fontSize: 16, color: Colors.deepPurple),
        border: const UnderlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          color: Colors.deepPurple,
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
