// lib/data/models/app_settings.dart
import 'package:flutter/material.dart';

@immutable
class AppSettings {
  final int characterDelay;
  final int phraseSpeed;
  final String lastConnectedDeviceId;
  final bool autoConnect;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final ThemeMode themeMode;

  const AppSettings({
    this.characterDelay = 500,
    this.phraseSpeed = 300,
    this.lastConnectedDeviceId = '',
    this.autoConnect = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.themeMode = ThemeMode.light,
  });

  AppSettings copyWith({
    int? characterDelay,
    int? phraseSpeed,
    String? lastConnectedDeviceId,
    bool? autoConnect,
    bool? soundEnabled,
    bool? vibrationEnabled,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      characterDelay: characterDelay ?? this.characterDelay,
      phraseSpeed: phraseSpeed ?? this.phraseSpeed,
      lastConnectedDeviceId: lastConnectedDeviceId ?? this.lastConnectedDeviceId,
      autoConnect: autoConnect ?? this.autoConnect,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          characterDelay == other.characterDelay &&
          phraseSpeed == other.phraseSpeed &&
          lastConnectedDeviceId == other.lastConnectedDeviceId &&
          autoConnect == other.autoConnect &&
          soundEnabled == other.soundEnabled &&
          vibrationEnabled == other.vibrationEnabled &&
          themeMode == other.themeMode;

  @override
  int get hashCode =>
      characterDelay.hashCode ^
      phraseSpeed.hashCode ^
      lastConnectedDeviceId.hashCode ^
      autoConnect.hashCode ^
      soundEnabled.hashCode ^
      vibrationEnabled.hashCode ^
      themeMode.hashCode;
}