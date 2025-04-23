import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  String? validatePassword(String value) {
    if (value.length < 8) return 'Must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value))
      return 'Must include uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value))
      return 'Must include lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must include number';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value))
      return 'Must include special character';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/sticky-notes.png', height: 140),
                const SizedBox(height: 10),
                Text(
                  "Create Account",
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Sign up to start sharing and downloading notes!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(controller: _name, hint: "Full Name"),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _email,
                        hint: "Email",
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                          controller: _password, hint: "Password"),
                      const SizedBox(height: 16),
                      _buildPasswordRules(),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: Text(
                                "Create Account",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      User? user = credential.user;
      await user!.updateDisplayName(_name.text.trim());

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': _name.text.trim(),
        'email': _email.text.trim(),
        'createdAt': Timestamp.now(),
      });

      await user.sendEmailVerification();

      setState(() => _isLoading = false);
      await showSuccessDialog(context);
      Get.toNamed('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = 'An error occurred';
      if (e.code == 'email-already-in-use') {
        errorMessage =
            'This account already exists for that email. Go and login.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      }
      showErrorDialog(context, errorMessage);
    } catch (e) {
      setState(() => _isLoading = false);
      showErrorDialog(context, 'Unexpected error: $e');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: (value) =>
          value == null || value.isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !_showPassword,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        return validatePassword(value);
      },
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _showPassword = !_showPassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildPasswordRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rule("At least 1 uppercase letter"),
        _rule("At least 1 lowercase letter"),
        _rule("At least 1 number"),
        _rule("At least 1 special character"),
        _rule("At least 8 characters"),
      ],
    );
  }

  Widget _rule(String text) {
    return Row(
      children: [
        const Icon(Icons.check, color: Colors.green, size: 18),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.poppins(fontSize: 13)),
      ],
    );
  }
}

Future<void> showSuccessDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 12),
          Text(
            'Sign up Success',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Don't forget to verify your email. Check your inbox.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    ),
  );
}

void showErrorDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Get.back(); // Close the dialog using GetX
            },
            child: const Icon(Icons.cancel, color: Colors.red, size: 60),
          ),
          const SizedBox(height: 12),
          Text(
            'Error',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    ),
  );
}
