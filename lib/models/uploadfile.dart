class UploadedFile {
  final String id;
  final String fileName;
  final String fileUrl;
  final String uploaderId;
  final String classId;
  final bool isInstructor;
  final String? gridFsFileId; // Nullable because it might not always be present
  final DateTime uploadedAt;

  UploadedFile({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.uploaderId,
    required this.classId,
    required this.isInstructor,
    this.gridFsFileId,
    required this.uploadedAt,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    const baseUrl =
        "http://192.168.57.232:3000"; // Replace with your server's IP
    return UploadedFile(
      id: json['id'] ?? '', // Default to empty string if null
      fileName: json['fileName'] ?? 'Unnamed File', // Default to 'Unnamed File'
      fileUrl: json['fileUrl'] != null
          ? "$baseUrl${json['fileUrl']}"
          : '', // Handle null fileUrl
      uploaderId:
          json['uploaderId'] ?? 'Unknown User', // Default to 'Unknown User'
      classId: json['classId'] ?? 'Unknown Class', // Default to 'Unknown Class'
      isInstructor: json['isInstructor'] ?? false, // Default to false
      gridFsFileId: json['gridFsFileId'], // Nullable
      uploadedAt: DateTime.tryParse(json['uploadedAt'] ?? '') ??
          DateTime.now(), // Default to current time
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'uploaderId': uploaderId,
        'classId': classId,
        'isInstructor': isInstructor,
        'gridFsFileId': gridFsFileId,
        'uploadedAt': uploadedAt.toIso8601String(),
      };
}
