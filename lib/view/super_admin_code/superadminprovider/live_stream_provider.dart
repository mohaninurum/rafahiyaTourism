import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LiveStreamProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _makkahUrl = '';
  String _madinahUrl = '';
  bool _isLoading = true;
  String _errorMessage = '';

  String get makkahUrl => _makkahUrl;
  String get madinahUrl => _madinahUrl;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  static const String defaultMakkahUrl = 'https://www.youtube.com/watch?v=your_default_makkah_video_id';
  static const String defaultMadinahUrl = 'https://www.youtube.com/watch?v=your_default_madinah_video_id';

  LiveStreamProvider(BuildContext context) {
    loadStreamUrls(context);
  }

  Future<void> loadStreamUrls(BuildContext context) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final doc = await _firestore.collection('liveStreams').doc('urls').get();

      if (doc.exists) {
        final data = doc.data()!;
        _makkahUrl = data['makkahUrl'] ?? defaultMakkahUrl;
        _madinahUrl = data['madinahUrl'] ?? defaultMadinahUrl;
      } else {
        _makkahUrl = defaultMakkahUrl;
        _madinahUrl = defaultMadinahUrl;
        await saveUrls(_makkahUrl, _madinahUrl, context);
      }

      await _validateUrls();

    } catch (e) {
      _errorMessage = 'Failed to load stream URLs: $e';
      _makkahUrl = defaultMakkahUrl;
      _madinahUrl = defaultMadinahUrl;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _validateUrls() async {
    try {
      final makkahVideoId = _extractVideoId(_makkahUrl);
      if (makkahVideoId.isEmpty) {
        print('Invalid Makkah URL, using default');
        _makkahUrl = defaultMakkahUrl;
      } else {
        final testController = YoutubePlayerController(
          initialVideoId: makkahVideoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: true,
          ),
        );

        await Future.delayed(Duration(milliseconds: 1000));

        final videoData = await testController.metadata;
        if (videoData == null) {
          throw Exception('Could not load video metadata');
        }

        testController.dispose();
      }

      final madinahVideoId = _extractVideoId(_madinahUrl);
      if (madinahVideoId.isEmpty) {
        print('Invalid Madinah URL, using default');
        _madinahUrl = defaultMadinahUrl;
      } else {
        final testController = YoutubePlayerController(
          initialVideoId: madinahVideoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: true,
          ),
        );

        await Future.delayed(Duration(milliseconds: 1000));

        final videoData = await testController.metadata;
        if (videoData == null) {
          throw Exception('Could not load video metadata');
        }

        testController.dispose();
      }
    } catch (e) {
      _errorMessage = 'URL validation failed: $e';
      print('URL validation error: $e');

      _makkahUrl = defaultMakkahUrl;
      _madinahUrl = defaultMadinahUrl;
    }
  }

  String _extractVideoId(String url) {
    try {
      if (url.contains('youtube.com/watch?v=')) {
        final uri = Uri.parse(url);
        return uri.queryParameters['v'] ?? '';
      } else if (url.contains('youtu.be/')) {
        final uri = Uri.parse(url);
        return uri.pathSegments.last;
      } else if (url.contains('youtube.com/embed/')) {
        final uri = Uri.parse(url);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty && segments.last != 'embed') {
          return segments.last;
        }
      } else if (url.length == 11 && !url.contains('/') && !url.contains('?')) {
        return url;
      } else if (url.contains('youtube.com/live/')) {
        final uri = Uri.parse(url);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty && segments.contains('live')) {
          final liveIndex = segments.indexOf('live');
          if (segments.length > liveIndex + 1) {
            String videoId = segments[liveIndex + 1];

            if (videoId.contains('?')) {
              videoId = videoId.split('?').first;
            }
            return videoId;
          }
        }
      }

      final videoId = YoutubePlayer.convertUrlToId(url);
      return videoId ?? '';
    } catch (e) {
      print('Error extracting video ID: $e');
      return '';
    }
  }

  Future<void> saveUrls(String makkahUrl, String madinahUrl, BuildContext context) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final makkahVideoId = _extractVideoId(makkahUrl);
      final madinahVideoId = _extractVideoId(madinahUrl);

      if (makkahVideoId.isEmpty || madinahVideoId.isEmpty) {
        throw Exception('Invalid YouTube URL provided');
      }

      await _firestore.collection('liveStreams').doc('urls').set({
        'makkahUrl': makkahUrl,
        'madinahUrl': madinahUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      _makkahUrl = makkahUrl;
      _madinahUrl = madinahUrl;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('URLs saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _errorMessage = 'Failed to save URLs: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save URLs: $e'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetToDefault() {
    _makkahUrl = defaultMakkahUrl;
    _madinahUrl = defaultMadinahUrl;
    notifyListeners();
  }
}