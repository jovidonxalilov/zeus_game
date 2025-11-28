import 'package:shared_preferences/shared_preferences.dart';

/// Storage manager for saving/loading game data
class StorageManager {
  static final StorageManager _instance = StorageManager._internal();
  factory StorageManager() => _instance;
  StorageManager._internal();
  
  SharedPreferences? _prefs;
  
  // Keys
  static const String _keyHighScore = 'high_score';
  static const String _keyCurrentLevel = 'current_level';
  static const String _keyTotalStars = 'total_stars';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keySfxEnabled = 'sfx_enabled';
  static const String _keyMusicVolume = 'music_volume';
  static const String _keySfxVolume = 'sfx_volume';
  static const String _keyCompletedLevels = 'completed_levels';
  static const String _keyPlayerName = 'player_name';
  static const String _keyTotalGames = 'total_games';
  static const String _keyZeusPower = 'zeus_power';
  
  /// Initialize storage
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // High Score
  Future<void> saveHighScore(int score) async {
    await _prefs?.setInt(_keyHighScore, score);
  }
  
  int getHighScore() {
    return _prefs?.getInt(_keyHighScore) ?? 0;
  }
  
  // Current Level
  Future<void> saveCurrentLevel(int level) async {
    await _prefs?.setInt(_keyCurrentLevel, level);
  }
  
  int getCurrentLevel() {
    return _prefs?.getInt(_keyCurrentLevel) ?? 1;
  }
  
  // Total Stars
  Future<void> saveTotalStars(int stars) async {
    await _prefs?.setInt(_keyTotalStars, stars);
  }
  
  int getTotalStars() {
    return _prefs?.getInt(_keyTotalStars) ?? 0;
  }
  
  // Music Settings
  Future<void> saveMusicEnabled(bool enabled) async {
    await _prefs?.setBool(_keyMusicEnabled, enabled);
  }
  
  bool getMusicEnabled() {
    return _prefs?.getBool(_keyMusicEnabled) ?? true;
  }
  
  // SFX Settings
  Future<void> saveSfxEnabled(bool enabled) async {
    await _prefs?.setBool(_keySfxEnabled, enabled);
  }
  
  bool getSfxEnabled() {
    return _prefs?.getBool(_keySfxEnabled) ?? true;
  }
  
  // Music Volume
  Future<void> saveMusicVolume(double volume) async {
    await _prefs?.setDouble(_keyMusicVolume, volume);
  }
  
  double getMusicVolume() {
    return _prefs?.getDouble(_keyMusicVolume) ?? 0.7;
  }
  
  // SFX Volume
  Future<void> saveSfxVolume(double volume) async {
    await _prefs?.setDouble(_keySfxVolume, volume);
  }
  
  double getSfxVolume() {
    return _prefs?.getDouble(_keySfxVolume) ?? 1.0;
  }
  
  // Completed Levels
  Future<void> saveCompletedLevels(List<int> levels) async {
    await _prefs?.setStringList(
      _keyCompletedLevels,
      levels.map((e) => e.toString()).toList(),
    );
  }
  
  List<int> getCompletedLevels() {
    final stringList = _prefs?.getStringList(_keyCompletedLevels) ?? [];
    return stringList.map((e) => int.parse(e)).toList();
  }
  
  // Player Name
  Future<void> savePlayerName(String name) async {
    await _prefs?.setString(_keyPlayerName, name);
  }
  
  String getPlayerName() {
    return _prefs?.getString(_keyPlayerName) ?? 'Zeus';
  }
  
  // Total Games
  Future<void> saveTotalGames(int games) async {
    await _prefs?.setInt(_keyTotalGames, games);
  }
  
  int getTotalGames() {
    return _prefs?.getInt(_keyTotalGames) ?? 0;
  }
  
  // Zeus Power Level
  Future<void> saveZeusPower(int power) async {
    await _prefs?.setInt(_keyZeusPower, power);
  }
  
  int getZeusPower() {
    return _prefs?.getInt(_keyZeusPower) ?? 1;
  }
  
  /// Clear all data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
