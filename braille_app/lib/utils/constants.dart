// lib/utils/constants.dart
class AppConstants {
  // UUIDs del servicio BLE
  static const String brailleServiceUUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String txCharacteristicUUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String rxCharacteristicUUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";

  // Comandos de control
  static const int commandPlay = 0x01;
  static const int commandPause = 0x02;
  static const int commandStop = 0x03;

  // Configuraciones por defecto
  static const int defaultCharacterDelay = 500;
  static const int defaultPhraseSpeed = 300;
  static const int minCharacterDelay = 100;
  static const int maxCharacterDelay = 5000;

  // Nombres de rutas
  static const String routeWelcome = '/';
  static const String routeHome = '/home';
}

class AppStrings {
  static const String appName = 'Braille App';
  static const String appDescription = 'Control ESP32 vía Bluetooth';
  static const String connected = 'Conectado';
  static const String disconnected = 'Desconectado';
  static const String scanning = 'Escaneando...';
  static const String connecting = 'Conectando...';
}