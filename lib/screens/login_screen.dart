import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;

  Future<void> loginUser() async {
    setState(() => _isLoading = true);
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        print("\x1B[32mGoogle Sign-In Successful:\x1B[0m"); // Cyan color
        print("\x1B[32mUID:\x1B[0m ${user.uid}"); // Cyan color
        print("\x1B[32mEmail:\x1B[0m ${user.email}"); // Cyan color
        print("\x1B[32mDisplay Name:\x1B[0m ${user.displayName}"); // Cyan color
      }
      await _showSuccessDialog("Login Successful!");

      // Delay before navigating to home screen
      // await Future.delayed(const Duration(seconds: 1));

      // Navigation to home screen
      Get.offNamed(
          '/home'); // Ensure '/home' is correctly set up in GetMaterialApp
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? "Login failed");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // await FirebaseAuth.instance.signInWithCredential(credential);
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Log user details in the console
        final User? user = userCredential.user;
        if (user != null) {
          print("\x1B[32mGoogle Sign-In Successful:\x1B[0m"); // Cyan color
          print("\x1B[32mUID:\x1B[0m ${user.uid}"); // Cyan color
          print("\x1B[32mEmail:\x1B[0m ${user.email}"); // Cyan color
          print(
              "\x1B[32mDisplay Name:\x1B[0m ${user.displayName}"); // Cyan color
        }
        await _showSuccessDialog("Google Sign-In Successful!");

        // // Delay before navigating to home screen
        // await Future.delayed(const Duration(seconds: 1));

        // Navigate to home screen
        Get.offNamed('/home');
      } else {
        _showErrorDialog("Google Sign-In was canceled.");
      }
    } catch (e) {
      _showErrorDialog("Google Sign-In failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
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
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/images/sticky-notes.png', height: 120),
                const SizedBox(height: 10),
                Text(
                  "Login",
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Enter your credentials to continue",
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _email,
                        hint: "Email",
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.blueAccent,
                              strokeWidth: 2,
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  loginUser();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: signInWithGoogle,
                        icon: Image.asset(
                          'assets/images/google.jpg',
                          height: 20,
                        ),
                        label: Text(
                          "Sign in with Google",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/signup');
                      },
                      child: Text(
                        "Sign up",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildPasswordField() {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          controller: _password,
          obscureText: !_showPassword,
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: "Password",
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog manually
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Welcome back!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
      ),
    );

    // Wait for 1 second before closing the dialog
    await Future.delayed(const Duration(milliseconds: 500));
    Get.back(); // Close the dialog
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 60),
            const SizedBox(height: 12),
            Text(
              'Login Failed',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
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
    await Future.delayed(const Duration(milliseconds: 500));
    Get.back(); // Close the dialog
  }
}
