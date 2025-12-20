import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../models/tutorial_videos_model.dart';

class TutorialVideoProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // UI state properties
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _currentOperation;
  List<TutorialVideo> _videos = [];
  bool _isLoading = false;

  // Getters for UI state
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get currentOperation => _currentOperation;
  List<TutorialVideo> get videos => _videos;
  bool get isLoading => _isLoading;

  // Reference to the collection
  CollectionReference get _tutorialVideosRef =>
      _firestore.collection('tutorial_videos');

  // Helper method to update UI state
  void _updateUIState({bool? isUploading, double? uploadProgress, String? currentOperation}) {
    if (isUploading != null) _isUploading = isUploading;
    if (uploadProgress != null) _uploadProgress = uploadProgress;
    if (currentOperation != null) _currentOperation = currentOperation;
    notifyListeners();
  }

  // Load all tutorial videos
  Future<void> loadTutorialVideos() async {
    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _tutorialVideosRef
          .orderBy('createdAt', descending: true)
          .get();

      _videos = querySnapshot.docs
          .map((doc) => TutorialVideo.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to load videos: $error');
    }
  }

  // Upload video to Firebase Storage and create document
  Future<String> uploadTutorialVideo({
    required File videoFile,
    required String title,
    required String description,
  }) async {
    try {
      _updateUIState(isUploading: true, uploadProgress: 0.0, currentOperation: 'Preparing upload');

      String videoId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload video to storage with progress tracking
      String fileName = 'tutorial_videos/$videoId/${DateTime.now().millisecondsSinceEpoch}.mp4';
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(videoFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        _updateUIState(uploadProgress: progress, currentOperation: 'Uploading video');
      });

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      _updateUIState(currentOperation: 'Saving video details');

      // Create document in Firestore
      TutorialVideo tutorialVideo = TutorialVideo(
        id: videoId,
        title: title,
        description: description,
        videoUrl: downloadUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _tutorialVideosRef.doc(videoId).set(tutorialVideo.toMap());

      // Refresh the videos list
      await loadTutorialVideos();

      _updateUIState(isUploading: false, uploadProgress: 1.0, currentOperation: 'Upload complete');

      return videoId;
    } catch (error) {
      _updateUIState(isUploading: false);
      throw Exception('Failed to upload video: $error');
    }
  }

  // Update an existing tutorial video
  Future<void> updateTutorialVideo({
    required String id,
    required String title,
    required String description,
    File? newVideoFile,
  }) async {
    try {
      _updateUIState(isUploading: true, uploadProgress: 0.0, currentOperation: 'Preparing update');

      String downloadUrl;

      // If a new video file is provided, upload it
      if (newVideoFile != null) {
        _updateUIState(currentOperation: 'Uploading new video');

        String fileName = 'tutorial_videos/$id/${DateTime.now().millisecondsSinceEpoch}.mp4';
        Reference storageRef = _storage.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(newVideoFile);

        // Listen to upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          _updateUIState(uploadProgress: progress);
        });

        TaskSnapshot snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      } else {
        // Keep the existing video URL
        DocumentSnapshot doc = await _tutorialVideosRef.doc(id).get();
        downloadUrl = doc.get('videoUrl');
      }

      _updateUIState(currentOperation: 'Updating video details');

      // Update document in Firestore
      await _tutorialVideosRef.doc(id).update({
        'title': title,
        'description': description,
        'videoUrl': downloadUrl,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Refresh the videos list
      await loadTutorialVideos();

      _updateUIState(isUploading: false, uploadProgress: 1.0, currentOperation: 'Update complete');
    } catch (error) {
      _updateUIState(isUploading: false);
      throw Exception('Failed to update video: $error');
    }
  }

  // Delete a tutorial video
  Future<void> deleteTutorialVideo(String id) async {
    try {
      // First delete the document
      await _tutorialVideosRef.doc(id).delete();

      // Then try to delete the video from storage (might have multiple versions)
      try {
        Reference storageRef = _storage.ref().child('tutorial_videos/$id');
        await storageRef.delete();
      } catch (e) {
        // Ignore storage deletion errors as the main document is deleted
        print('Error deleting storage files: $e');
      }

      // Refresh the videos list
      await loadTutorialVideos();
    } catch (error) {
      throw Exception('Failed to delete video: $error');
    }
  }
}