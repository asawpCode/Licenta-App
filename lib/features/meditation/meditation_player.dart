import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:untitled/features/meditation/meditation_feedback.dart';
import 'package:untitled/services/user_data.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dart:math';

class PlayerScreen extends StatefulWidget {
  final String trackName;
  final String trackType;
  final String trackUrl;
  final int duration;
  final bool isInteractive;

  const PlayerScreen({
    super.key,
    required this.trackName,
    required this.trackType,
    required this.trackUrl,
    required this.duration,
    this.isInteractive = true,
  });

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _elapsedTime = Duration.zero;
  bool _isDisposed = false;
  Duration? _totalDuration;
  Duration? _desiredDuration;
  final UserStatsService _userStatsService = UserStatsService();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _desiredDuration = Duration(minutes: widget.duration);
    _fetchAudioUrl();
    _audioPlayer.positionStream.listen((position) {
      if (!_isDisposed) {
        setState(() {
          _elapsedTime = position;
          if (!widget.isInteractive && _elapsedTime >= _desiredDuration!) {
            _stopPlayback();
          }
        });
      }
    });
    _audioPlayer.playerStateStream.listen((state) {
      if (!_isDisposed) {
        if (state.processingState == ProcessingState.completed) {
          _stopPlayback();
        }
      }
    });
    _audioPlayer.durationStream.listen((duration) {
      if (!_isDisposed) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchAudioUrl() async {
    try {
      final url =
          await FirebaseStorage.instance.ref(widget.trackUrl).getDownloadURL();
      if (!_isDisposed) {
        await _audioPlayer.setUrl(url);
        if (!_isDisposed) {
          _audioPlayer.play();
          setState(() {
            _isLoading = false;
            _isPlaying = true;
          });
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Eroare la preluarea audio-ului: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _stopPlayback() {
    _audioPlayer.stop();
    int minutesPlayed =
        widget.isInteractive ? _elapsedTime.inMinutes : widget.duration;
    _userStatsService.updateMeditationStats(minutesPlayed, widget.trackName);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MeditationFeedbackPage(meditationName: widget.trackName),
        ),
      );
    }
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxDurationInSeconds = (widget.isInteractive
            ? _totalDuration?.inSeconds.toDouble()
            : _desiredDuration?.inSeconds.toDouble()) ??
        0.0;
    double sliderValue =
        min(max(0, _elapsedTime.inSeconds.toDouble()), maxDurationInSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            _audioPlayer.stop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Lottie.asset(
            'android/assets/videos/bg5.json',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            repeat: true,
            animate: true,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.trackName,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.trackType,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Durata: ${widget.duration} min',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                const SizedBox(height: 150),
                Slider(
                  value: sliderValue,
                  max: maxDurationInSeconds,
                  min: 0,
                  onChanged: widget.isInteractive
                      ? (value) {
                          _audioPlayer.seek(Duration(seconds: value.toInt()));
                          setState(() {
                            _elapsedTime = Duration(seconds: value.toInt());
                          });
                        }
                      : null,
                  divisions: widget.isInteractive ? 60 : null,
                  activeColor: widget.isInteractive
                      ? const Color.fromARGB(255, 111, 1, 255)
                      : Colors.grey,
                ),
                Text(
                  '${(_elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}:${(_elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  IconButton(
                    icon: Icon(_isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled),
                    color: Colors.white,
                    iconSize: 80,
                    onPressed: _togglePlayPause,
                  ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
