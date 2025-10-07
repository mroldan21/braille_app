// lib/utils/validators.dart
class Validators {
  static String? validateCharacter(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un carácter';
    }
    
    if (value.length > 1) {
      return 'Solo se permite un carácter';
    }
    
    const validChars = 'abcdefghijklmnopqrstuvwxyz0123456789,.!?;:- ';
    if (!validChars.contains(value.toLowerCase())) {
      return 'Carácter no soportado';
    }
    
    return null;
  }

  static String? validatePhrase(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una frase';
    }
    
    if (value.length > 500) {
      return 'La frase no puede tener más de 500 caracteres';
    }
    
    return null;
  }
}