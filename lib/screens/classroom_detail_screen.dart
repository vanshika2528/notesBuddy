import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/uploadfile.dart';

class ClassroomDetailPage extends StatefulWidget {
  final String classId;
  final String className;
  final String currentUserId;
  final String tag;
  final String instructor; // NEW

  ClassroomDetailPage({
    required this.classId,
    required this.className,
    required this.currentUserId,
    required this.tag,
    required this.instructor,
  });

  @override
  _ClassroomDetailPageState createState() => _ClassroomDetailPageState();
}

class _ClassroomDetailPageState extends State<ClassroomDetailPage> {
  final ip = "192.168.57.232";
  File? _pickedFile;
  List<UploadedFile> _uploadedFiles = [];
  // final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _saveFileLocally(pickedFile);
    }
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _pickedFile = file;
      });
      Get.snackbar("Success", "PDF selected: ${result.files.single.name}");
    }
  }

  Future<void> _saveFileLocally(XFile pickedFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = pickedFile.name;
    final localPath = '${directory.path}/$fileName';
    final file = File(localPath);

    await file.writeAsBytes(await pickedFile.readAsBytes());

    setState(() {
      _pickedFile = file;
    });
  }

  Future<void> _uploadFileToMongo() async {
    if (_pickedFile == null) {
      Get.snackbar("Error", "No file selected");
      return;
    }

    try {
      final uri = Uri.parse("http://$ip:3000/upload");
      print("Uploading file to: $uri"); // Debug log

      var request = http.MultipartRequest('POST', uri);
      request.fields['uploaderId'] = widget.currentUserId;
      request.fields['classId'] = widget.classId;
      request.fields['isInstructor'] = (widget.tag == "Instructor").toString();

      // Add the file with proper content type
      final fileExtension = _pickedFile!.path.split('.').last.toLowerCase();
      final contentType = fileExtension == 'pdf'
          ? MediaType('application', 'pdf')
          : MediaType('image', fileExtension);

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _pickedFile!.path,
        contentType: contentType,
      ));

      print("Sending request..."); // Debug log
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("Response status: ${response.statusCode}"); // Debug log
      print("Response body: $responseBody"); // Debug log

      if (response.statusCode == 201) {
        Get.snackbar("Success", "File uploaded successfully");
        _fetchUploadedFiles(); // Refresh the file list
      } else {
        Get.snackbar(
            "Error", "Upload failed: ${response.statusCode}\n$responseBody");
      }
    } catch (e) {
      print("Error uploading file: $e"); // Debug log
      Get.snackbar("Error", "Failed to upload file: $e");
    }
  }

  Future<void> _fetchUploadedFiles() async {
    if (widget.classId.isEmpty) {
      print("Error: classId is empty or null");
      return;
    }

    final uri = Uri.parse("http://$ip:3000/files/${widget.classId}");
    print("Fetching files from: $uri"); // Debug log

    try {
      final response = await http.get(uri);
      print("Response status: ${response.statusCode}"); // Debug log

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print("Server Response: $jsonData"); // Log the response

        setState(() {
          _uploadedFiles = List.from(jsonData)
              .map((file) => UploadedFile.fromJson(file))
              .toList();
        });
      } else if (response.statusCode == 404) {
        print("No files found for classId: ${widget.classId}");
        setState(() {
          _uploadedFiles = []; // Clear the list if no files are found
        });
      } else {
        print("Failed to load files: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching files: $e"); // Log the full error
    }
  }

  Future<void> _deleteFile(String fileId) async {
    final uri = Uri.parse("http://$ip:3000/delete/$fileId");

    try {
      final response = await http.delete(
        uri,
        headers: {
          'userId': widget.currentUserId, // Pass the current user ID
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "File deleted successfully");
        _fetchUploadedFiles(); // Refresh the file list
      } else {
        Get.snackbar(
          "Permission Denied",
          "Only instructors can delete files.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error deleting file: $e");
      Get.snackbar("Error", "Failed to delete file: $e");
    }
  }

  Future<void> _downloadFile(String fileName) async {
    final uri =
        Uri.parse("http://$ip:3000/file/$fileName"); // Backend download route
    final tempDir = await getTemporaryDirectory(); // Get temporary directory
    final filePath = '${tempDir.path}/$fileName'; // File path to save the file

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes); // Save file locally

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File downloaded to $filePath")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to download file: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error downloading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading file: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUploadedFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: _pickedFile == null
                  ? Text("No file selected", style: TextStyle(fontSize: 20))
                  : _pickedFile!.path.endsWith('.pdf')
                      ? Text(
                          "PDF Selected: ${_pickedFile!.path.split('/').last}")
                      : Image.file(_pickedFile!),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _uploadFileToMongo,
              icon: Icon(Icons.cloud_upload, color: Colors.white),
              label: Text("Upload File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Text("Uploaded Files",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6, // Adjust height
              child: ListView.builder(
                itemCount: _uploadedFiles.length,
                itemBuilder: (context, index) {
                  final file = _uploadedFiles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: file.fileName.endsWith('.pdf')
                          ? Icon(Icons.picture_as_pdf, color: Colors.red)
                          : (file.fileUrl.isNotEmpty
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.image,
                                        color: Colors.green), // Image icon
                                    const SizedBox(
                                        width:
                                            8), // Spacing between icon and thumbnail
                                    Image.network(
                                      file.fileUrl,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.broken_image,
                                            color: Colors.grey);
                                      },
                                    ),
                                  ],
                                )
                              : Icon(Icons.insert_drive_file,
                                  color: Colors.blue)),
                      title: Text(
                        file.fileName.isNotEmpty
                            ? file.fileName
                            : "Unnamed File",
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.download, color: Colors.blue),
                            onPressed: () =>
                                _downloadFile(file.fileName), // Download file
                          ),
                          if (widget.tag == "Instructor")
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteFile(
                                    file.id); // Allow deletion for instructors
                              },
                            ),
                        ],
                      ),
                      onTap: file.fileUrl.isNotEmpty
                          ? () => launchUrl(Uri.parse(file.fileUrl))
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blueAccent,
        children: [
          SpeedDialChild(
            child: Icon(Icons.image, color: Colors.white),
            backgroundColor: Colors.green,
            label: 'Upload Image',
            onTap: _pickImage,
          ),
          SpeedDialChild(
            child: Icon(Icons.picture_as_pdf, color: Colors.white),
            backgroundColor: Colors.red,
            label: 'Upload PDF',
            onTap: _pickPDF,
          ),
        ],
      ),
    );
  }
}
