import 'package:just_audio/just_audio.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {}
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  Future<List<Map<String, String>>> fetchAudioUrlsWithNames(
      String folder) async {
    firebase_storage.ListResult result =
        await firebase_storage.FirebaseStorage.instance.ref(folder).listAll();

    List<Map<String, String>> urlsWithNames = [];
    for (var ref in result.items) {
      String url = await ref.getDownloadURL();
      String name = ref.name;
      urlsWithNames.add({'url': url, 'name': name});
    }
    return urlsWithNames;
  }

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  AudioPlayer get audioPlayer => _audioPlayer;
}
