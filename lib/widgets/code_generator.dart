import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class GenerateClassroomCode extends StatefulWidget {
  @override
  _GenerateClassroomCodeState createState() => _GenerateClassroomCodeState();
}

class _GenerateClassroomCodeState extends State<GenerateClassroomCode> {
  TextEditingController _nameController = TextEditingController();
  bool isLoading = false;
  String? generatedCode;

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  Future<void> _createClassroom() async {
    setState(() => isLoading = true);

    final String className = _nameController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (className.isEmpty || user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Enter a valid class name')));
      setState(() => isLoading = false);
      return;
    }

    final code = _generateRandomCode();
    final classData = {
      'name': className,
      'instructor': user.email ?? 'Unknown',
      'createdAt': FieldValue.serverTimestamp(),
      'tag': 'Instructor',
      'createdBy': user.uid,
    };

    await FirebaseFirestore.instance
        .collection('classrooms_master')
        .doc(code)
        .set(classData);

    setState(() {
      generatedCode = code;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Classroom created! Code: $code')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Classroom Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Classroom Name'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createClassroom,
                    child: Text(
                      'Generate Code',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 21, 105, 251),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            if (generatedCode != null) ...[
              SizedBox(height: 20),
              Text(
                'Generated Code: $generatedCode',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 16, 16, 16)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
