import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_buddy/firebase_options.dart';
import 'package:note_buddy/screens/home_screen.dart';
import 'package:note_buddy/screens/login_screen.dart';
import 'package:note_buddy/screens/profile_screen.dart';
import 'package:note_buddy/screens/signup_screen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_buddy/widgets/code_generator.dart';
import 'package:note_buddy/widgets/drawer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_api_availability/google_api_availability.dart';
// import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // final GoogleSignIn googleSignIn = GoogleSignIn();
  // await googleSignIn.signOut();
  await ensureProviderInstaller();
  runApp(MyApp());
}

Future<void> ensureProviderInstaller() async {
  try {
    final availability = await GoogleApiAvailability.instance
        .checkGooglePlayServicesAvailability();
    if (availability == GooglePlayServicesAvailability.success) {
      print("Google Play Services is available.");
    } else {
      print("Google Play Services is not available: $availability");
    }
  } catch (e) {
    print("Error ensuring ProviderInstaller: $e");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // home: LoginScreen(),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/code', page: () => GenerateClassroomCode()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
      ],
    );
  }
}
