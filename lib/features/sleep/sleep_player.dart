import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:untitled/services/notification_service.dart';

class SleepPlayerScreen extends StatefulWidget {
  final String trackName;
  final String trackUrl;
  final String trackType;
  final String wakeUpTime;

  const SleepPlayerScreen({
    super.key,
    required this.trackName,
    required this.trackUrl,
    required this.trackType,
    required this.wakeUpTime,
    required int duration,
  });

  @override
  _SleepPlayerScreenState createState() => _SleepPlayerScreenState();
}

class _SleepPlayerScreenState extends State<SleepPlayerScreen>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  late DateTime _wakeUpTime;
  Timer? _timer;
  String _timeLeft = "Se calculează...";
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _audioPlayer = AudioPlayer();
    _wakeUpTime = DateTime.parse(widget.wakeUpTime);
    _adjustWakeUpTimeIfNeeded();
    _initializeAudioPlayer();
    _notificationService = NotificationService(onNotificationTap: _quitSleep);
    WidgetsBinding.instance?.addObserver(this);
  }

  void _adjustWakeUpTimeIfNeeded() {
    final now = DateTime.now();
    if (_wakeUpTime.isBefore(now)) {
      _wakeUpTime = _wakeUpTime.add(const Duration(days: 1));
    }

    final localTime = tz.TZDateTime.from(_wakeUpTime, tz.local);
    _wakeUpTime = localTime;
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.trackUrl);
      _audioPlayer.setLoopMode(LoopMode.one);
      _audioPlayer.play();
      _startTimer();
    } catch (e) {
      print("Nu s-a putut incarcă audio-ul: $e");
    }
  }

  void _startTimer() {
    final now = DateTime.now();
    final difference = _wakeUpTime.difference(now);

    if (difference <= Duration.zero) {
      _notificationService.showWakeUpNotification();
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final currentTime = DateTime.now();
      final timeLeft = _wakeUpTime.difference(currentTime);

      if (timeLeft <= Duration.zero) {
        timer.cancel();
        _audioPlayer.stop();
        _notificationService.showWakeUpNotification();
      } else {
        setState(() {
          _timeLeft = _formatDuration(timeLeft);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  void _quitSleep() {
    _audioPlayer.stop();
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  void deactivate() {
    _audioPlayer.stop();
    _timer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 23, 27, 73),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _quitSleep,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _quitSleep,
          ),
        ],
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.trackName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.trackType,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Timp pană la alarmă: $_timeLeft',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 200),
                ElevatedButton(
                  onPressed: _quitSleep,
                  child: const Text('Opreste'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 247, 247, 247),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
