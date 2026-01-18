import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movieverse/core/constants/app_constants.dart';
import 'package:movieverse/presentation/providers/auth_provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoUrl;
  final int movieId; // Added for history tracking
  
  const VideoPlayerScreen({super.key, required this.videoUrl, required this.movieId});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final user = ref.read(authStateProvider).value;
    Duration initialPos = Duration.zero;

    // Fetch history
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(AppConstants.historyCollection)
            .where('uid', isEqualTo: user.uid)
            .where('movieId', isEqualTo: widget.movieId)
            .limit(1)
            .get();
        
        if (doc.docs.isNotEmpty) {
           final data = doc.docs.first.data();
           final ms = data['progress'] as int? ?? 0;
           initialPos = Duration(milliseconds: ms);
        }
      } catch (e) {
        // Ignore
      }
    }

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();
    
    if (initialPos > Duration.zero && initialPos < _videoPlayerController.value.duration) {
      await _videoPlayerController.seekTo(initialPos);
    }
    
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        allowedScreenSleep: false,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
      _initialized = true;
    });

    _videoPlayerController.addListener(_onVideoProgress);
  }

  void _onVideoProgress() {
    if (!_videoPlayerController.value.isPlaying) return;
    
    // throttle saving? Or save on dispose. 
    // Real-time saving is DB heavy. Let's save on pause/dispose.
  }

  Future<void> _saveProgress() async {
    if (!_initialized) return;
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final position = _videoPlayerController.value.position.inMilliseconds;
    
    // Upsert logic
    final query = FirebaseFirestore.instance.collection(AppConstants.historyCollection)
        .where('uid', isEqualTo: user.uid)
        .where('movieId', isEqualTo: widget.movieId);
        
    final snapshots = await query.get();
    
    if (snapshots.docs.isNotEmpty) {
      await snapshots.docs.first.reference.update({
        'progress': position,
        'watchedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await FirebaseFirestore.instance.collection(AppConstants.historyCollection).add({
        'uid': user.uid,
        'movieId': widget.movieId,
        'progress': position,
        'watchedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  void dispose() {
    _saveProgress(); // Fire and forget?
    _videoPlayerController.removeListener(_onVideoProgress);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}
