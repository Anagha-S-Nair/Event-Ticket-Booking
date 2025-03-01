import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool currentPassVisible = false;
  bool newPassVisible = false;
  bool confirmPassVisible = false;

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String oldPassword = "dummyOldPassword"; // Replace with actual fetched password

  Future<void> updatePassword() async {
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            "Change Password",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildPasswordField(Icons.lock_outline, "Current Password", currentPasswordController, currentPassVisible, () {
              setState(() => currentPassVisible = !currentPassVisible);
            }),
            buildPasswordField(Icons.lock, "New Password", newPasswordController, newPassVisible, () {
              setState(() => newPassVisible = !newPassVisible);
            }),
            buildPasswordField(Icons.lock, "Confirm Password", confirmPasswordController, confirmPassVisible, () {
              setState(() => confirmPassVisible = !confirmPassVisible);
            }),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 234, 146, 88),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "SAVE CHANGES",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPasswordField(IconData icon, String label, TextEditingController controller, bool obscureText, VoidCallback toggleVisibility) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggleVisibility,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
