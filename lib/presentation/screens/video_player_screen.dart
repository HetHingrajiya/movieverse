import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoUrl;
  final int movieId;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.movieId,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  // Chewie
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // YouTube
  YoutubePlayerController? _youtubeController;
  bool _isYoutube = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (videoId != null) {
      // It's a YouTube URL
      _isYoutube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
      setState(() {});
    } else {
      // Standard Video URL
      _isYoutube = false;
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      setState(() {});
      _videoPlayerController!.addListener(_onVideoProgress);
    }
  }

  void _onVideoProgress() {
    if (_videoPlayerController?.value.isPlaying ?? false) {
      // Save progress logic
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_onVideoProgress);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildPlayer(),
      ),
    );
  }

  Widget _buildPlayer() {
    if (_isYoutube) {
      return _youtubeController != null
          ? YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
            )
          : const Center(child: CircularProgressIndicator());
    } else {
      return _chewieController != null &&
              _videoPlayerController!.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : const Center(child: CircularProgressIndicator());
    }
  }
}
