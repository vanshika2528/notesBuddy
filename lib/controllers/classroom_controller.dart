import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassroomController extends GetxController {
  var classrooms = [].obs;
  var isJoining = false.obs;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('classrooms')
          .snapshots()
          .listen((snapshot) {
        classrooms.value = snapshot.docs.map((e) {
          final data = e.data();
          return {
            'id': data['id'] ?? e.id,
// Default to empty string
            'name': data['name'] ?? 'Classroom', // Default to 'Classroom'
            'instructor':
                data['instructor'] ?? 'Unknown', // Default to 'Unknown'
            'tag': data['tag'] ?? 'student', // Default to empty string
          };
        }).toList();
      });
    }
    super.onInit();
  }

  Future<void> joinClass(String classCode) async {
    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }

    isJoining.value = true;
    classCode = classCode.trim();

    print("Trying to fetch class: $classCode");

    final classRef = FirebaseFirestore.instance
        .collection('classrooms_master')
        .doc(classCode);

    try {
      final classDoc = await classRef.get();

      if (!classDoc.exists) {
        Get.snackbar("Error", "Class code does not exist!");
        isJoining.value = false;
        return;
      }

      final userClassRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('classrooms')
          .doc(classCode);

      final alreadyJoined = await userClassRef.get(); // <-- FIXED HERE

      if (alreadyJoined.exists) {
        Get.snackbar("Info", "You already joined this class!");
        isJoining.value = false;
        return;
      }

      // Save classroom data with ID
      await userClassRef.set({
        ...classDoc.data()!,
        'id': classDoc.id,
      });

      Get.snackbar("Success", "Joined classroom successfully!");
    } catch (e) {
      print("Error joining class: $e");
      Get.snackbar("Error", "Something went wrong!");
    } finally {
      isJoining.value = false;
    }
  }
}
