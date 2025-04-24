# 📚 NotesBuddy – Your Smart Notes Sharing App

**NotesBuddy** is a powerful Flutter application designed to simplify the way you manage and share academic and personal notes. Whether it’s a scanned image, handwritten notes, or a full PDF – this app allows users to **upload**, **store**, and **download** files seamlessly.

---

## ✨ Features

- 📤 Upload notes (PDF and image format)
- 📥 Download any uploaded note with a tap
- 🗂 Organized note storage
- 🧾 View note details (name, file type, etc.)
- 🔐 Secure and scalable backend with Firebase
- 🌐 Image & PDF storage using MongoDB GridFS
- 🎯 Fast, responsive & user-friendly UI built with Flutter

---

## 🛠 Tech Stack

| Technology     | Role                                       |
|----------------|--------------------------------------------|
| **Flutter**     | Cross-platform mobile UI development      |
| **Firebase**    | Authentication and real-time data sync    |
| **MongoDB**     | Storage for uploaded files (PDF/image)    |
| **Node.js** | Backend API for file handling   |
| **GridFS**      | MongoDB module to store large files       |

---

## 📸 Screenshots

> *(All screenshots are stored in the `/note_buddy_app_ss` folder)*

### 🔐 Login Screen
![Login](./note_buddy_app_ss/login.jpeg)

### 📝 Sign Up with Google
![Signup with Google](./note_buddy_app_ss/signupWithGoogle.jpeg)

### ✅ Google Sign-in Success
![Google Sign-in](./note_buddy_app_ss/googleSignlNSuccessfully.jpeg)

### 🏠 Home Screen
![Home](./note_buddy_app_ss/homeScreen.jpeg)


### 📋 Menu
![Menu](./note_buddy_app_ss/menu.jpeg)

### 🧾 Generate Class Code
![Generate Class Code](./note_buddy_app_ss/generateClassCode.jpeg)

### 📚 Join Class
![Join Class](./note_buddy_app_ss/joinClass.jpeg)

### 📂 File Upload
![File Upload](./note_buddy_app_ss/fileUpload.jpeg)

### 📑 View Uploaded Files
![View File](./note_buddy_app_ss/viewFileUpload.jpeg)


## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- Firebase project setup
- MongoDB Atlas (or local) with GridFS enabled
- Node.js backend

### Setup Instructions


1. **Clone the repository**
```bash
git clone https://github.com/vanshika2528/notesBuddy.git
cd notesbuddy
```

Make sure your Firebase is initialized in the firebase_options.dart file.

Install dependencies

```bash
flutter pub get

```
Run the app
```bash

flutter run
```

## 🚀 Run the Backend

### 1. Navigate to the backend folder

```bash
cd backend
```
### 2. Install dependencies
```bash
npm install
```
### 3. Set up environment variables

Create a .env file in the backend directory and add your MongoDB connection string:
```bash
MONGO_URI=your_mongodb_connection_string
PORT=3000
```
### 4. Run the server
To start the backend server, run:
```bash
node server.js 
```

# 📈 Future Enhancements
- ✅ Add note categorization (subject-wise)
- 🔍 Search functionality for uploaded notes
- 🌓 Dark mode support
- 👥 User-specific note filtering
- 🌍 Multi-language support
