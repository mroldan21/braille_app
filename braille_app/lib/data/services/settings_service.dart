// lib/data/services/settings_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _characterDelayKey = 'character_delay';
  static const String _phraseSpeedKey = 'phrase_speed';
  static const String _lastDeviceKey = 'last_device';
  static const String _autoConnectKey = 'auto_connect';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _themeModeKey = 'theme_mode';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return AppSettings(
      characterDelay: prefs.getInt(_characterDelayKey) ?? 500,
      phraseSpeed: prefs.getInt(_phraseSpeedKey) ?? 300,
      lastConnectedDeviceId: prefs.getString(_lastDeviceKey) ?? '',
      autoConnect: prefs.getBool(_autoConnectKey) ?? true,
      soundEnabled: prefs.getBool(_soundEnabledKey) ?? true,
      vibrationEnabled: prefs.getBool(_vibrationEnabledKey) ?? true,
      themeMode: ThemeMode.values[prefs.getInt(_themeModeKey) ?? 0],
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_characterDelayKey, settings.characterDelay);
    await prefs.setInt(_phraseSpeedKey, settings.phraseSpeed);
    await prefs.setString(_lastDeviceKey, settings.lastConnectedDeviceId);
    await prefs.setBool(_autoConnectKey, settings.autoConnect);
    await prefs.setBool(_soundEnabledKey, settings.soundEnabled);
    await prefs.setBool(_vibrationEnabledKey, settings.vibrationEnabled);
    await prefs.setInt(_themeModeKey, settings.themeMode.index);
  }

  Future<void> saveLastDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDeviceKey, deviceId);
  }

  Future<String> getLastDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastDeviceKey) ?? '';
  }
}