// lib/presentation/providers/settings_provider.dart
import 'package:flutter/material.dart';
import '../../data/models/app_settings.dart';
import '../../data/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    _settings = await _settingsService.loadSettings();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _settingsService.saveSettings(newSettings);
    notifyListeners();
  }

  Future<void> updateCharacterDelay(int delay) async {
    _settings = _settings.copyWith(characterDelay: delay);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updatePhraseSpeed(int speed) async {
    _settings = _settings.copyWith(phraseSpeed: speed);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLastDevice(String deviceId) async {
    _settings = _settings.copyWith(lastConnectedDeviceId: deviceId);
    await _settingsService.saveLastDevice(deviceId);
    notifyListeners();
  }

  Future<void> toggleAutoConnect(bool value) async {
    _settings = _settings.copyWith(autoConnect: value);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleSound(bool value) async {
    _settings = _settings.copyWith(soundEnabled: value);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleVibration(bool value) async {
    _settings = _settings.copyWith(vibrationEnabled: value);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    _settings = _settings.copyWith(themeMode: themeMode);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
}