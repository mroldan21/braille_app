#include <ESP8266WiFi.h>
#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include "BrailleDevice.h"
#include "BLEService.h"
#include "config.h"

BrailleDevice brailleDevice;
BLEService bleService;

void setup() {
  Serial.begin(115200);
  Serial.println("Iniciando Dispositivo Braille...");
  
  // Inicializar pines Braille
  brailleDevice.begin();
  
  // Inicializar BLE
  bleService.begin("Braille-ESP32");
  
  Serial.println("Dispositivo listo. Esperando conexión BLE...");
  Serial.println("Nombre del dispositivo: Braille-ESP32");
}

void loop() {
  // Verificar si hay nuevos comandos BLE
  if (bleService.hasNewCommand()) {
    BLECommand command = bleService.getLastCommand();
    processCommand(command);
  }
  
  // Mantener funcionamiento del dispositivo Braille
  brailleDevice.update();
  
  delay(10); // Pequeño delay para evitar sobrecarga
}

void processCommand(BLECommand command) {
  Serial.printf("Procesando comando: Tipo=0x%02X, Data=0x%02X, Duration=%dms\n", 
                command.type, command.data, command.duration);
  
  switch (command.type) {
    case 0x01: // Comando de carácter Braille
      Serial.printf("Carácter Braille: 0x%02X\n", command.data);
      brailleDevice.displayCharacter(command.data, command.duration);
      break;
      
    case 0x02: // Comando de control
      processControlCommand(command.data);
      break;
      
    default:
      Serial.printf("Comando desconocido: 0x%02X\n", command.type);
      break;
  }
}

void processControlCommand(uint8_t controlCode) {
  switch (controlCode) {
    case 0x01: // Play
      Serial.println("Comando: PLAY");
      brailleDevice.play();
      break;
      
    case 0x02: // Pause
      Serial.println("Comando: PAUSE");
      brailleDevice.pause();
      break;
      
    case 0x03: // Stop
      Serial.println("Comando: STOP");
      brailleDevice.stop();
      break;
      
    default:
      Serial.printf("Comando de control desconocido: 0x%02X\n", controlCode);
      break;
  }
}