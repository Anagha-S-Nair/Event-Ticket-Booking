import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_eventticket/components/form_validation.dart';
import 'package:user_eventticket/main.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool currentPassVisible = false;
  bool newPassVisible = false;
  bool confirmPassVisible = false;

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> updatePassword() async {
    try {
      // First, verify the old password by attempting to sign in
      final response = await supabase.auth.signInWithPassword(
        email: supabase.auth.currentUser!.email!,
        password: currentPasswordController.text,
      );

      if (response.user == null) {
        throw Exception('Current password is incorrect');
      }

      // If sign in was successful, update the password
      await supabase.auth.updateUser(
        UserAttributes(
          password: newPasswordController.text,
        ),
      );

      await supabase.from('tbl_user').update({
        'user_password': newPasswordController.text,
      }).eq('id', supabase.auth.currentUser!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('incorrect')
              ? 'Current password is incorrect'
              : 'Failed to change password'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
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
            buildPasswordField(Icons.lock_outline, "Current Password",
                currentPasswordController, currentPassVisible, () {
              setState(() => currentPassVisible = !currentPassVisible);
            },(p0) => FormValidation.validatePassword(p0),),
            buildPasswordField(Icons.lock, "New Password",
                newPasswordController, newPassVisible, () {
              setState(() => newPassVisible = !newPassVisible);
            },(p0) => FormValidation.validatePassword(p0),),
            buildPasswordField(Icons.lock, "Confirm Password",
                confirmPasswordController, confirmPassVisible, () {
              setState(() => confirmPassVisible = !confirmPassVisible);
            },(p0) => FormValidation.validateConfirmPassword(p0, newPasswordController.text),),
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

  Widget buildPasswordField(
    IconData icon,
    String label,
    TextEditingController controller,
    bool obscureText,
    VoidCallback toggleVisibility,
    String? Function(String?)? validator, // Added validator parameter
  ) {
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
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: label,
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              ),
            ),
            validator: validator, // Added validator here
          ),
        ),
      ],
    ),
  );
}

}
