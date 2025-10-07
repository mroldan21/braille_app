// lib/data/services/ble_service.dart
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/ble_device.dart';
import '../models/braille_character.dart';

class BLEService {
  // Elimina la instancia, ya no es necesaria
  final StreamController<List<BLEDevice>> _devicesController =
      StreamController<List<BLEDevice>>.broadcast();
  final StreamController<bool> _connectionController = 
      StreamController<bool>.broadcast();
  
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _txCharacteristic;
  
  Stream<List<BLEDevice>> get devicesStream => _devicesController.stream;
  Stream<bool> get connectionState => _connectionController.stream;
  
  // UUIDs del servicio Braille personalizado
  static const String serviceUUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String txCharacteristicUUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String rxCharacteristicUUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";

  Future<bool> initialize() async {
    try {
      // Verificar si Bluetooth está soportado
      bool isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) return false;

      // Verificar si Bluetooth está encendido
      final state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> startScan() async {
    // Limpiar dispositivos anteriores
    _devicesController.add([]);
    
    // Escanear dispositivos
    FlutterBluePlus.scanResults.listen((results) {
      final devices = results.where((result) {
        // Filtrar dispositivos con el servicio Braille
        return result.device.platformName.contains("Braille") ||
               result.advertisementData.serviceUuids.contains(Guid(serviceUUID));
      }).map((result) => BLEDevice(
        id: result.device.remoteId.str,
        name: result.device.platformName,
        serviceUUID: serviceUUID,
        isConnected: false,
        rssi: result.rssi,
      )).toList();
      
      _devicesController.add(devices);
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<bool> connectToDevice(String deviceId) async {
    try {
      // Buscar dispositivo
      final devices = await FlutterBluePlus.systemDevices([]); // Se pasa una lista vacía para obtener todos
      BluetoothDevice? targetDevice;
      
      for (var device in devices) {
        if (device.remoteId.str == deviceId) {
          targetDevice = device;
          break;
        }
      }
      
      if (targetDevice == null) {
        // Escanear para encontrar el dispositivo
        await startScan();
        await Future.delayed(const Duration(seconds: 2));
        await stopScan();
        
        final scanResults = await FlutterBluePlus.scanResults.first;
        for (var result in scanResults) {
          if (result.device.remoteId.str == deviceId) {
            targetDevice = result.device;
            break;
          }
        }
      }
      
      if (targetDevice == null) return false;
      
      // Conectar al dispositivo
      await targetDevice.connect();
      _connectedDevice = targetDevice;
      
      // Descubrir servicios
      final services = await targetDevice.discoverServices();
      final brailleService = services.firstWhere(
        (service) => service.uuid.toString().toLowerCase() == serviceUUID,
      );
      
      // Obtener características
      _txCharacteristic = brailleService.characteristics.firstWhere(
        (char) => char.uuid.toString().toLowerCase() == txCharacteristicUUID,
      );
      
      _connectionController.add(true);
      return true;
    } catch (e) {
      _connectionController.add(false);
      return false;
    }
  }

  Future<bool> sendBrailleCommand(BrailleCharacter braille, {int duration = 500}) async {
    try {
      if (_txCharacteristic == null) return false;
      
      final command = braille.toCommand(duration: duration);
      await _txCharacteristic!.write(command);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendControlCommand(List<int> command) async {
    try {
      if (_txCharacteristic == null) return false;
      await _txCharacteristic!.write(command);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> autoReconnect(String deviceId) async {
    try {
      return await connectToDevice(deviceId);
    } catch (e) {
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
      _connectedDevice = null;
      _txCharacteristic = null;
      _connectionController.add(false);
    } catch (e) {
      // Ignorar errores de desconexión
    }
  }

  void dispose() {
    _devicesController.close();
    _connectionController.close();
  }
}