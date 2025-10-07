import 'package:flutter/foundation.dart';

@immutable
class BrailleCharacter {
  final String character;
  final List<bool> points; // [p1, p2, p3, p4, p5, p6]
  final int byteValue;

  const BrailleCharacter({
    required this.character,
    required this.points,
    required this.byteValue,
  });

  factory BrailleCharacter.fromChar(String char) {
    final lowerChar = char.toLowerCase();
    
    // Mapeo completo de caracteres a Braille
    final brailleMap = {
      'a': [true, false, false, false, false, false],
      'b': [true, true, false, false, false, false],
      'c': [true, false, false, true, false, false],
      'd': [true, false, false, true, true, false],
      'e': [true, false, false, false, true, false],
      'f': [true, true, false, true, false, false],
      'g': [true, true, false, true, true, false],
      'h': [true, true, false, false, true, false],
      'i': [false, true, false, true, false, false],
      'j': [false, true, false, true, true, false],
      'k': [true, false, true, false, false, false],
      'l': [true, true, true, false, false, false],
      'm': [true, false, true, true, false, false],
      'n': [true, false, true, true, true, false],
      'o': [true, false, true, false, true, false],
      'p': [true, true, true, true, false, false],
      'q': [true, true, true, true, true, false],
      'r': [true, true, true, false, true, false],
      's': [false, true, true, true, false, false],
      't': [false, true, true, true, true, false],
      'u': [true, false, true, false, false, true],
      'v': [true, true, true, false, false, true],
      'w': [false, true, false, true, true, true],
      'x': [true, false, true, true, false, true],
      'y': [true, false, true, true, true, true],
      'z': [true, false, true, false, true, true],
      '0': [false, true, false, true, true, false],
      '1': [true, false, false, false, false, false],
      '2': [true, true, false, false, false, false],
      '3': [true, false, false, true, false, false],
      '4': [true, false, false, true, true, false],
      '5': [true, false, false, false, true, false],
      '6': [true, true, false, true, false, false],
      '7': [true, true, false, true, true, false],
      '8': [true, true, false, false, true, false],
      '9': [false, true, false, true, false, false],
      ',': [false, true, false, false, false, false],
      '.': [false, true, false, false, true, true],
      '!': [false, true, true, false, true, false],
      '?': [false, true, false, false, true, false],
      ';': [false, true, true, false, false, false],
      ':': [false, true, false, false, true, false],
      '-': [false, false, true, false, false, true],
      ' ': [false, false, false, false, false, false],
    };

    final points = brailleMap[lowerChar] ?? [false, false, false, false, false, false];
    final byteValue = _pointsToByteValue(points);

    return BrailleCharacter(
      character: char,
      points: points,
      byteValue: byteValue,
    );
  }

  static int _pointsToByteValue(List<bool> points) {
    int value = 0;
    for (int i = 0; i < points.length; i++) {
      if (points[i]) {
        value |= (1 << i);
      }
    }
    return value;
  }

  List<int> toCommand({int duration = 500}) {
    // [HEADER][COMMAND_TYPE][DATA][DURATION_HIGH][DURATION_LOW][CHECKSUM]
    final List<int> command = [
      0xAA, // Header
      0x01, // Command type: Carácter Braille
      byteValue, // Data
      (duration >> 8) & 0xFF, // Duration high byte
      duration & 0xFF, // Duration low byte
    ];
    
    // Calculate checksum (XOR)
    int checksum = 0;
    for (int byte in command) {
      checksum ^= byte;
    }
    command.add(checksum);
    
    return command;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrailleCharacter &&
          runtimeType == other.runtimeType &&
          character == other.character;

  @override
  int get hashCode => character.hashCode;

  @override
  String toString() => 'BrailleCharacter(char: $character, byte: 0x${byteValue.toRadixString(16)})';
}