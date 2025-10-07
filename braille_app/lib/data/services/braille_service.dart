import 'dart:math';
import '../models/braille_character.dart';

enum CharCategory { letters, numbers, mixed }

class BrailleService {
  static final BrailleService _instance = BrailleService._internal();
  factory BrailleService() => _instance;
  BrailleService._internal();

  final Random _random = Random();

  /// Convierte un carácter individual a Braille
  BrailleCharacter convertToBraille(String character) {
    if (character.isEmpty) {
      return BrailleCharacter.fromChar(' ');
    }
    return BrailleCharacter.fromChar(character[0]);
  }

  /// Convierte una frase completa a lista de caracteres Braille
  List<BrailleCharacter> convertPhrase(String phrase) {
    if (phrase.isEmpty) return [];
    
    return phrase.split('').map((char) {
      return BrailleCharacter.fromChar(char);
    }).toList();
  }

  /// Genera un carácter aleatorio según la categoría
  String generateRandomChar(CharCategory category) {
    switch (category) {
      case CharCategory.letters:
        const letters = 'abcdefghijklmnopqrstuvwxyz';
        return letters[_random.nextInt(letters.length)];
      
      case CharCategory.numbers:
        return _random.nextInt(10).toString();
      
      case CharCategory.mixed:
        const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
        return chars[_random.nextInt(chars.length)];
    }
  }

  /// Valida si un carácter es soportado
  bool isValidCharacter(String char) {
    if (char.isEmpty) return false;
    const validChars = 'abcdefghijklmnopqrstuvwxyz0123456789,.!?;:- ';
    return validChars.contains(char.toLowerCase());
  }

  /// Calcula el tiempo total para una frase en milisegundos
  int calculatePhraseDuration(String phrase, int characterDelay) {
    return phrase.length * characterDelay;
  }

  /// Calcula la velocidad en palabras por minuto
  int calculateWPM(int characterDelayMs) {
    // Asumiendo 5 caracteres promedio por palabra
    const avgCharsPerWord = 5;
    final charsPerMinute = (60000 / characterDelayMs);
    return (charsPerMinute / avgCharsPerWord).round();
  }

  /// Calcula el delay entre caracteres desde WPM
  int calculateDelayFromWPM(int wpm) {
    const avgCharsPerWord = 5;
    final charsPerMinute = wpm * avgCharsPerWord;
    return (60000 / charsPerMinute).round();
  }

  /// Obtiene todos los caracteres soportados
  List<String> getSupportedCharacters() {
    return [
      ...'abcdefghijklmnopqrstuvwxyz'.split(''),
      ...'0123456789'.split(''),
      ',', '.', '!', '?', ';', ':', '-', ' '
    ];
  }

  /// Genera un comando de control para el ESP32
  List<int> generateControlCommand(int commandType) {
    // [HEADER][COMMAND_TYPE][DATA][DURATION_HIGH][DURATION_LOW][CHECKSUM]
    final List<int> command = [
      0xAA, // Header
      0x02, // Command type: Control
      commandType, // 0x01=play, 0x02=pause, 0x03=stop
      0x00, // Duration high byte (N/A for control)
      0x00, // Duration low byte
    ];
    
    int checksum = 0;
    for (int byte in command) {
      checksum ^= byte;
    }
    command.add(checksum);
    
    return command;
  }
}