import 'package:flutter/foundation.dart';
import '../../data/models/ble_device.dart';
import '../../data/models/braille_character.dart';
import '../../data/services/ble_service.dart';

class BLEProvider extends ChangeNotifier {
  final BLEService _bleService = BLEService();

  List<BLEDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnected = false;
  BLEDevice? _connectedDevice;
  String _statusMessage = 'Desconectado';

  List<BLEDevice> get devices => _devices;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  BLEDevice? get connectedDevice => _connectedDevice;
  String get statusMessage => _statusMessage;

  BLEProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final success = await _bleService.initialize();
    if (!success) {
      _statusMessage = 'Bluetooth no disponible';
      notifyListeners();
      return;
    }

    // Escuchar cambios de conexión
    _bleService.connectionState.listen((connected) {
      _isConnected = connected;
      _statusMessage = connected ? 'Conectado' : 'Desconectado';
      notifyListeners();
    });

    // Escuchar dispositivos encontrados
    _bleService.devicesStream.listen((devices) {
      _devices = devices;
      notifyListeners();
    });
  }

  /// Inicia el escaneo de dispositivos
  Future<void> startScan() async {
    _isScanning = true;
    _statusMessage = 'Escaneando...';
    notifyListeners();

    await _bleService.startScan();

    await Future.delayed(const Duration(seconds: 10));
    await stopScan();
  }

  /// Detiene el escaneo
  Future<void> stopScan() async {
    await _bleService.stopScan();
    _isScanning = false;
    _statusMessage = _isConnected ? 'Conectado' : 'Desconectado';
    notifyListeners();
  }

  /// Conecta a un dispositivo
  Future<bool> connectToDevice(BLEDevice device) async {
    _statusMessage = 'Conectando...';
    notifyListeners();

    final success = await _bleService.connectToDevice(device.id);
    
    if (success) {
      _connectedDevice = device.copyWith(isConnected: true);
      _isConnected = true;
      _statusMessage = 'Conectado a ${device.name}';
    } else {
      _statusMessage = 'Error de conexión';
    }
    
    notifyListeners();
    return success;
  }

  /// Desconecta del dispositivo actual
  Future<void> disconnect() async {
    await _bleService.disconnect();
    _connectedDevice = null;
    _isConnected = false;
    _statusMessage = 'Desconectado';
    notifyListeners();
  }

  /// Envía un carácter Braille
  Future<bool> sendBrailleCharacter(BrailleCharacter braille, int duration) async {
    if (!_isConnected) return false;
    return await _bleService.sendBrailleCommand(braille, duration: duration);
  }

  /// Envía un comando de control
  Future<bool> sendControlCommand(List<int> command) async {
    if (!_isConnected) return false;
    return await _bleService.sendControlCommand(command);
  }

  /// Reconexión automática
  Future<bool> autoReconnect(String deviceId) async {
    _statusMessage = 'Reconectando...';
    notifyListeners();
    
    final success = await _bleService.autoReconnect(deviceId);
    
    if (!success) {
      _statusMessage = 'Falló reconexión';
      notifyListeners();
    }
    
    return success;
  }

  @override
  void dispose() {
    _bleService.dispose();
    super.dispose();
  }
}