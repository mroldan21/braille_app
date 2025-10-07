// lib/data/models/ble_device.dart
import 'package:flutter/foundation.dart';

@immutable
class BLEDevice {
  final String id;
  final String name;
  final String serviceUUID;
  final bool isConnected;
  final int rssi;

  const BLEDevice({
    required this.id,
    required this.name,
    required this.serviceUUID,
    required this.isConnected,
    required this.rssi,
  });

  BLEDevice copyWith({
    String? id,
    String? name,
    String? serviceUUID,
    bool? isConnected,
    int? rssi,
  }) {
    return BLEDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceUUID: serviceUUID ?? this.serviceUUID,
      isConnected: isConnected ?? this.isConnected,
      rssi: rssi ?? this.rssi,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BLEDevice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BLEDevice{id: $id, name: $name, connected: $isConnected, rssi: $rssi}';
  }
}