import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:note_buddy/screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: MediaQuery.of(context).size.height *
                0.16, // Set the desired height here
            color: Colors.blueAccent,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 24, left: 20),
            // padding: EdgeInsets.all(20),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text('Generate Classroom Code'),
            onTap: () {
              // Navigate to generate class page
              Get.back(); // Closes the drawer
              Get.toNamed('/code'); // Navigate to the '/code' route
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              GetPage(name: '/profile', page: () => ProfileScreen());
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Change Theme'),
            onTap: () {
              // Implement theme toggle logic
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
