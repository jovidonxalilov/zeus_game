/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, [this.code]);
  
  @override
  String toString() => message;
}

/// Game exceptions
class GameException extends AppException {
  GameException(super.message, [super.code]);
}

class InvalidMoveException extends GameException {
  InvalidMoveException([String? message])
      : super(message ?? 'Noto\'g\'ri harakat', 'INVALID_MOVE');
}

class NoMatchesException extends GameException {
  NoMatchesException([String? message])
      : super(message ?? 'Hech qanday moslik topilmadi', 'NO_MATCHES');
}

class InsufficientEnergyException extends GameException {
  InsufficientEnergyException([String? message])
      : super(message ?? 'Energiya yetarli emas', 'INSUFFICIENT_ENERGY');
}

class LevelLockedException extends GameException {
  LevelLockedException([String? message])
      : super(message ?? 'Daraja qulflangan', 'LEVEL_LOCKED');
}

/// Storage exceptions
class StorageException extends AppException {
  StorageException(super.message, [super.code]);
}

class SaveException extends StorageException {
  SaveException([String? message])
      : super(message ?? 'Ma\'lumotni saqlashda xatolik', 'SAVE_ERROR');
}

class LoadException extends StorageException {
  LoadException([String? message])
      : super(message ?? 'Ma\'lumotni yuklashda xatolik', 'LOAD_ERROR');
}

/// Audio exceptions
class AudioException extends AppException {
  AudioException(super.message, [super.code]);
}

class AudioLoadException extends AudioException {
  AudioLoadException([String? message])
      : super(message ?? 'Audio faylni yuklashda xatolik', 'AUDIO_LOAD_ERROR');
}

class AudioPlayException extends AudioException {
  AudioPlayException([String? message])
      : super(message ?? 'Audio faylni ijro etishda xatolik', 'AUDIO_PLAY_ERROR');
}
