#ifndef BLESERVICE_H
#define BLESERVICE_H

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include "config.h"

struct BLECommand {
  uint8_t type;
  uint8_t data;
  uint16_t duration;
};

class BLEService {
private:
  BLEServer* pServer = nullptr;
  BLEService* pService = nullptr;
  BLECharacteristic* pTxCharacteristic = nullptr;
  BLECharacteristic* pRxCharacteristic = nullptr;
  
  bool deviceConnected = false;
  bool oldDeviceConnected = false;
  
  BLECommand lastCommand;
  bool newCommandAvailable = false;
  
  // Callbacks para BLE
  class ServerCallbacks: public BLEServerCallbacks {
    private:
      BLEService* parent;
    public:
      ServerCallbacks(BLEService* p) : parent(p) {}
      
      void onConnect(BLEServer* pServer) {
        parent->deviceConnected = true;
        Serial.println("Dispositivo conectado");
      };

      void onDisconnect(BLEServer* pServer) {
        parent->deviceConnected = false;
        Serial.println("Dispositivo desconectado");
      }
  };

  class CharacteristicCallbacks: public BLECharacteristicCallbacks {
    private:
      BLEService* parent;
    public:
      CharacteristicCallbacks(BLEService* p) : parent(p) {}
      
      void onWrite(BLECharacteristic* pCharacteristic) {
        std::string rxValue = pCharacteristic->getValue();
        
        if (rxValue.length() == 6) {
          // Validar checksum
          uint8_t checksum = 0;
          for (int i = 0; i < 5; i++) {
            checksum ^= rxValue[i];
          }
          
          if (checksum == rxValue[5]) {
            // Comando válido
            parent->lastCommand.type = rxValue[1];
            parent->lastCommand.data = rxValue[2];
            parent->lastCommand.duration = (rxValue[3] << 8) | rxValue[4];
            parent->newCommandAvailable = true;
            
            Serial.printf("Comando recibido - Tipo: 0x%02X, Data: 0x%02X, Duration: %d\n",
                         parent->lastCommand.type, parent->lastCommand.data, parent->lastCommand.duration);
          } else {
            Serial.println("Error: Checksum inválido");
          }
        } else {
          Serial.printf("Error: Longitud de comando inválida: %d\n", rxValue.length());
        }
      }
  };

public:
  void begin(const char* deviceName) {
    // Crear dispositivo BLE
    BLEDevice::init(deviceName);
    
    // Crear servidor BLE
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks(this));
    
    // Crear servicio BLE
    pService = pServer->createService(SERVICE_UUID);
    
    // Crear característica para recepción (RX)
    pRxCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_RX,
      BLECharacteristic::PROPERTY_WRITE
    );
    pRxCharacteristic->setCallbacks(new CharacteristicCallbacks(this));
    
    // Crear característica para transmisión (TX)
    pTxCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_TX,
      BLECharacteristic::PROPERTY_NOTIFY
    );
    pTxCharacteristic->addDescriptor(new BLE2902());
    
    // Iniciar servicio
    pService->start();
    
    // Iniciar advertising
    BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);  // Funciona con iPhone
    pAdvertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();
    
    Serial.println("Servicio BLE iniciado. Esperando conexión...");
  }
  
  bool hasNewCommand() {
    return newCommandAvailable;
  }
  
  BLECommand getLastCommand() {
    newCommandAvailable = false;
    return lastCommand;
  }
  
  bool isConnected() {
    return deviceConnected;
  }
  
  void sendResponse(const char* response) {
    if (deviceConnected) {
      pTxCharacteristic->setValue(response);
      pTxCharacteristic->notify();
    }
  }
  
  void update() {
    // Manejar reconexión
    if (!deviceConnected && oldDeviceConnected) {
      delay(500); // Dar tiempo para que se complete la desconexión
      pServer->startAdvertising();
      Serial.println("Reiniciando advertising...");
      oldDeviceConnected = deviceConnected;
    }
    
    if (deviceConnected && !oldDeviceConnected) {
      oldDeviceConnected = deviceConnected;
    }
  }
};

#endif