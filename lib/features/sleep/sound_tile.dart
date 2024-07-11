import 'package:flutter/material.dart';
import 'package:untitled/features/sleep/timepicker.dart';
import 'package:untitled/services/audio_service.dart';

class SoundTile extends StatefulWidget {
  final String title;
  final String soundUrl;
  final AudioService audioService;
  final Function(String, DateTime) onAudioSelected;
  final Function() stopCurrentAudio;

  const SoundTile({
    super.key,
    required this.title,
    required this.soundUrl,
    required this.audioService,
    required this.onAudioSelected,
    required this.stopCurrentAudio,
  });

  @override
  _SoundTileState createState() => _SoundTileState();
}

class _SoundTileState extends State<SoundTile> {
  bool isPlaying = false;

  void _togglePlayPause(BuildContext context) {
    if (isPlaying) {
      widget.audioService.pauseAudio();
    } else {
      widget.audioService.playAudio(widget.soundUrl);
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _handleAudioSelected() async {
    if (isPlaying) {
      widget.audioService.pauseAudio();
      setState(() {
        isPlaying = false;
      });
    }

    final DateTime? selectedTime = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return const TimePickerWidget();
      },
    );

    if (selectedTime != null) {
      widget.onAudioSelected(widget.soundUrl, selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleAudioSelected,
      child: ListTile(
        leading: const Icon(Icons.music_note),
        title: Text(widget.title),
        trailing: IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            _togglePlayPause(context);
          },
        ),
      ),
    );
  }
}
