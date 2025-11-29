import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  void setMuted(bool muted) {
    _isMuted = muted;
  }

  bool get isMuted => _isMuted;

  Future<void> playClick() => _playSound('click.mp3');
  Future<void> playMatch() => _playSound('match.mp3');
  Future<void> playVictory() => _playSound('victory.mp3');
  Future<void> playExplosion() => _playSound('explosion.mp3');
  Future<void> playFailure() => _playSound('failure.mp3');
  Future<void> playFall() => _playSound('fall.mp3');
  Future<void> playLightning() => _playSound('lightning.mp3');
  Future<void> playPowerup() => _playSound('powerup.mp3');
  Future<void> playWhoosh() => _playSound('whoosh.mp3');

  Future<void> _playSound(String fileName) async {
    if (_isMuted) return;

    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      // Silent fail - file might not exist
      print('🔇 Sound not found: $fileName');
    }
  }

  void dispose() {
    _player.dispose();
  }
}