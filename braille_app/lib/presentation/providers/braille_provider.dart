// lib/presentation/providers/braille_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/models/braille_character.dart';
import '../../data/services/braille_service.dart';

class BrailleProvider extends ChangeNotifier {
  final BrailleService _brailleService = BrailleService();
  
  BrailleCharacter? _currentCharacter;
  List<BrailleCharacter> _currentPhrase = [];
  int _currentPhraseIndex = 0;
  bool _isPlayingPhrase = false;
  String _lastRandomChar = '';

  BrailleCharacter? get currentCharacter => _currentCharacter;
  List<BrailleCharacter> get currentPhrase => _currentPhrase;
  int get currentPhraseIndex => _currentPhraseIndex;
  bool get isPlayingPhrase => _isPlayingPhrase;
  String get lastRandomChar => _lastRandomChar;

  /// Convierte y establece un carácter individual
  void setCharacter(String char) {
    if (char.isEmpty) return;
    
    _currentCharacter = _brailleService.convertToBraille(char);
    _currentPhrase = [];
    _currentPhraseIndex = 0;
    _isPlayingPhrase = false;
    
    notifyListeners();
  }

  /// Convierte y establece una frase completa
  void setPhrase(String phrase) {
    _currentPhrase = _brailleService.convertPhrase(phrase);
    _currentCharacter = null;
    _currentPhraseIndex = 0;
    _isPlayingPhrase = false;
    
    notifyListeners();
  }

  /// Genera un carácter aleatorio
  void generateRandomChar(CharCategory category) {
    _lastRandomChar = _brailleService.generateRandomChar(category);
    _currentCharacter = _brailleService.convertToBraille(_lastRandomChar);
    _currentPhrase = [];
    _currentPhraseIndex = 0;
    _isPlayingPhrase = false;
    
    notifyListeners();
  }

  /// Obtiene el siguiente carácter en la frase
  BrailleCharacter? getNextPhraseCharacter() {
    if (_currentPhrase.isEmpty || _currentPhraseIndex >= _currentPhrase.length) {
      return null;
    }
    
    final character = _currentPhrase[_currentPhraseIndex];
    _currentPhraseIndex++;
    
    if (_currentPhraseIndex >= _currentPhrase.length) {
      _isPlayingPhrase = false;
    }
    
    notifyListeners();
    return character;
  }

  /// Inicia la reproducción de la frase
  void startPhrasePlayback() {
    if (_currentPhrase.isEmpty) return;
    
    _currentPhraseIndex = 0;
    _isPlayingPhrase = true;
    notifyListeners();
  }

  /// Pausa la reproducción de la frase
  void pausePhrasePlayback() {
    _isPlayingPhrase = false;
    notifyListeners();
  }

  /// Detiene la reproducción de la frase
  void stopPhrasePlayback() {
    _currentPhraseIndex = 0;
    _isPlayingPhrase = false;
    notifyListeners();
  }

  /// Valida si un carácter es soportado
  bool isValidCharacter(String char) {
    return _brailleService.isValidCharacter(char);
  }

  /// Obtiene todos los caracteres soportados
  List<String> getSupportedCharacters() {
    return _brailleService.getSupportedCharacters();
  }

  /// Calcula la duración total de la frase
  int calculatePhraseDuration(int characterDelay) {
    return _currentPhrase.length * characterDelay;
  }

  /// Obtiene el progreso actual de la frase (0.0 a 1.0)
  double getPhraseProgress() {
    if (_currentPhrase.isEmpty) return 0.0;
    return _currentPhraseIndex / _currentPhrase.length;
  }

  /// Reinicia el estado
  void clear() {
    _currentCharacter = null;
    _currentPhrase = [];
    _currentPhraseIndex = 0;
    _isPlayingPhrase = false;
    notifyListeners();
  }
}