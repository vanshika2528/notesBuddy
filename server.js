require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const multer = require('multer');
const { GridFsStorage } = require('multer-gridfs-storage');
const { GridFSBucket } = require('mongodb');
const crypto = require('crypto');
const path = require('path');

const app = express();
app.use(express.json());

// MongoDB connection
const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/gridfs_db';

mongoose.connect(mongoURI, { useNewUrlParser: true, useUnifiedTopology: true });
const conn = mongoose.connection;

let gridfsBucket;

conn.once('open', () => {
  gridfsBucket = new GridFSBucket(conn.db, {
    bucketName: 'uploads',
  });
  console.log('MongoDB connected and GridFSBucket initialized');
});

// File metadata schema
const fileSchema = new mongoose.Schema({
  fileName: String,
  fileUrl: String,
  uploaderId: String,
  classId: String,
  isInstructor: Boolean,
  gridFsFileId: mongoose.Types.ObjectId,
  uploadedAt: {
    type: Date,
    default: Date.now,
  },
});

const File = mongoose.model('File', fileSchema);

// GridFS storage configuration
const storage = new GridFsStorage({
  url: mongoURI,
  file: (req, file) => {
    return new Promise((resolve, reject) => {
      crypto.randomBytes(16, (err, buf) => {
        if (err) return reject(err);
        const filename = buf.toString('hex') + path.extname(file.originalname);
        resolve({
          filename: filename,
          bucketName: 'uploads',
        });
      });
    });
  },
});

const upload = multer({ storage });

// Upload route
app.post('/upload', upload.single('file'), async (req, res) => {
  const fileUrl = `/file/${req.file.filename}`;

  const fileMetadata = {
    fileName: req.file.filename,
    fileUrl,
    uploaderId: req.body.uploaderId,
    classId: req.body.classId,
    isInstructor: req.body.isInstructor === 'true',
    gridFsFileId: req.file.id,
  };

  try {
    const savedFile = await File.create(fileMetadata);
    res.status(201).json({ message: 'File uploaded successfully', file: savedFile });
  } catch (error) {
    console.error('Error saving file metadata:', error);
    res.status(500).send('Error saving file metadata');
  }
});

// Delete route
app.delete('/delete/:fileId', async (req, res) => {
  const { userId, isInstructor } = req.headers;

  try {
    const file = await File.findById(req.params.fileId);
    if (!file) return res.status(404).send('File metadata not found');

    if (file.uploaderId !== userId && isInstructor !== 'true') {
      return res.status(403).send('Only the instructor or uploader can delete this file');
    }

    await gridfsBucket.delete(file.gridFsFileId);
    await File.findByIdAndDelete(req.params.fileId);

    res.status(200).send('File and metadata deleted');
  } catch (err) {
    console.error('Error deleting file:', err.message);
    res.status(500).send('Error deleting file');
  }
});

// Download route
app.get('/file/:filename', async (req, res) => {
  try {
    const downloadStream = gridfsBucket.openDownloadStreamByName(req.params.filename);
    downloadStream.pipe(res);
  } catch (error) {
    console.error('Error retrieving file:', error.message);
    res.status(500).send('Error retrieving file');
  }
}
);

// Fetch files for a specific class
app.get('/files/:classId', async (req, res) => {
  try {
    console.log(`Fetching files for classId: ${req.params.classId}`);
    const files = await File.find({ classId: req.params.classId }).sort({ uploadedAt: -1 });

    if (!files || files.length === 0) {
      console.log(`No files found for classId: ${req.params.classId}`);
      return res.status(404).json({ message: 'No files found for this class' });
    }

    const cleanedFiles = files.map(file => ({
      id: file._id.toString(),
      fileName: file.fileName,
      fileUrl: `/file/${file.fileName}`,
      uploaderId: file.uploaderId,
      classId: file.classId,
      isInstructor: file.isInstructor,
      gridFsFileId: file.gridFsFileId?.toString(),
      uploadedAt: file.uploadedAt,
    }));

    res.status(200).json(cleanedFiles);
  } catch (err) {
    console.error('Error fetching files:', err.message);
    res.status(500).json({ message: 'Error fetching files', error: err.message });
  }
});

// Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));