import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_buddy/screens/classroom_detail_screen.dart';
import '../widgets/drawer.dart';
import '../controllers/classroom_controller.dart';

class HomePage extends StatelessWidget {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final ClassroomController controller = Get.put(ClassroomController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "NotesBuddy",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: Obx(() {
        if (controller.classrooms.isEmpty) {
          return Center(
            child: Text(
              'Join a classroom to get started!',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.classrooms.length,
          itemBuilder: (context, index) {
            final data = controller.classrooms[index];
            final classId = data['id'];
            final className = data['name'];
            final tag = data['tag'] ?? '';
            final instructor =
                data['instructor'] ?? 'Unknown'; // Default to empty string
            return GestureDetector(
              onTap: () {
                if (classId != null && classId.toString().isNotEmpty) {
                  Get.to(() => ClassroomDetailPage(
                        classId: classId ?? '',
                        className: className ?? 'Classroom',
                        currentUserId: currentUserId ?? '',
                        tag: tag,
                        instructor: instructor,
                      ));
                } else {
                  Get.snackbar('Error', 'Invalid classroom ID');
                }
              },
              child: Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  title: Text(
                    className ?? 'No Name',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "Instructor: $instructor",
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJoinDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Join Classroom',
        backgroundColor: Colors.blueAccent, // Set the background color to blue
        foregroundColor: Colors.white, // Set the icon color to white
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    TextEditingController _codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return Obx(() => AlertDialog(
              title: Text("Join a Class", style: GoogleFonts.poppins()),
              content: TextField(
                controller: _codeController,
                decoration: InputDecoration(hintText: "Enter Class Code"),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    String code = _codeController.text.trim();
                    if (code.isEmpty) {
                      Get.snackbar("Error", "Class code cannot be empty");
                      return;
                    }

                    await controller.joinClass(code);
                    Navigator.pop(context);
                  },
                  child: controller.isJoining.value
                      ? CircularProgressIndicator()
                      : Text(
                          "Join",
                          style: GoogleFonts.poppins(
                            color: const Color.fromARGB(255, 37, 116, 251),
                          ),
                        ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel",
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 37, 116, 251),
                      )),
                ),
              ],
            ));
      },
    );
  }
}
