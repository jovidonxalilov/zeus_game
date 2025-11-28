import 'package:audioplayers/audioplayers.dart';

/// Audio manager for game sounds and music
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();
  
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  double _musicVolume = 0.7;
  double _sfxVolume = 1.0;
  
  // Getters
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  
  /// Initialize audio
  Future<void> initialize() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      print('Audio initialization warning: $e');
      // Don't throw error, just log
    }
  }
  
  /// Play background music
  Future<void> playMusic(String assetPath) async {
    if (!_musicEnabled) return;
    
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setVolume(_musicVolume);
      // Try to play, but don't crash if file doesn't exist
      await _musicPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Warning: Could not play music: $assetPath. Error: $e');
      // Silently fail - game continues without music
    }
  }
  
  /// Stop background music
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      print('Warning: Could not stop music: $e');
    }
  }
  
  /// Play sound effect
  Future<void> playSfx(String assetPath) async {
    if (!_sfxEnabled) return;
    
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
      // Try to play, but don't crash if file doesn't exist
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Warning: Could not play SFX: $assetPath. Error: $e');
      // Silently fail - game continues without sound
    }
  }
  
  /// Toggle music
  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) {
      stopMusic();
    }
  }
  
  /// Toggle sound effects
  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
  }
  
  /// Set music volume
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    try {
      _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      print('Warning: Could not set music volume: $e');
    }
  }
  
  /// Set SFX volume
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    try {
      _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      print('Warning: Could not set SFX volume: $e');
    }
  }
  
  /// Dispose audio players
  void dispose() {
    try {
      _musicPlayer.dispose();
      _sfxPlayer.dispose();
    } catch (e) {
      print('Warning: Could not dispose audio: $e');
    }
  }
}

/// Sound effects enum
enum GameSound {
  gemMatch,
  gemSwap,
  gemFall,
  lightning,
  explosion,
  powerUp,
  victory,
  defeat,
  buttonClick,
}

extension GameSoundExtension on GameSound {
  String get assetPath {
    switch (this) {
      case GameSound.gemMatch:
        return 'sounds/match.mp3';
      case GameSound.gemSwap:
        return 'sounds/whoosh.mp3';
      case GameSound.gemFall:
        return 'sounds/fall.mp3';
      case GameSound.lightning:
        return 'sounds/lightning.mp3';
      case GameSound.explosion:
        return 'sounds/explosion.mp3';
      case GameSound.powerUp:
        return 'sounds/powerup.mp3';
      case GameSound.victory:
        return 'sounds/victory.mp3';
      case GameSound.defeat:
        return 'sounds/defeat.mp3';
      case GameSound.buttonClick:
        return 'sounds/click.mp3';
    }
  }
}