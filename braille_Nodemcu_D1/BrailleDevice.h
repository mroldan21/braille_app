#ifndef BRAILLEDEVICE_H
#define BRAILLEDEVICE_H

#include <Arduino.h>
#include "config.h"

#ifdef USE_SERVOS
  #include <Servo.h>
#endif

class BrailleDevice {
private:
  #ifdef USE_SERVOS
    Servo servos[6];
  #else
    int pins[6] = {PIN_POINT_1, PIN_POINT_2, PIN_POINT_3, PIN_POINT_4, PIN_POINT_5, PIN_POINT_7};
  #endif
  
  bool currentPoints[6] = {false, false, false, false, false, false};
  unsigned long activationTime[6] = {0, 0, 0, 0, 0, 0};
  unsigned long duration[6] = {0, 0, 0, 0, 0, 0};
  
  bool isPlaying = false;
  bool isPaused = false;

public:
  void begin() {
    Serial.println("Inicializando dispositivo Braille...");
    
    #ifdef USE_SERVOS
      // Inicializar servomotores
      servos[0].attach(PIN_POINT_1);
      servos[1].attach(PIN_POINT_2);
      servos[2].attach(PIN_POINT_3);
      servos[3].attach(PIN_POINT_4);
      servos[4].attach(PIN_POINT_5);
      servos[5].attach(PIN_POINT_7);
      
      // Mover todos a posición inicial (abajo)
      for (int i = 0; i < 6; i++) {
        servos[i].write(SERVO_ANGLE_DOWN);
      }
      Serial.println("Servomotores inicializados");
      
    #else
      // Inicializar pines para solenoides
      for (int i = 0; i < 6; i++) {
        pinMode(pins[i], OUTPUT);
        digitalWrite(pins[i], LOW);
      }
      Serial.println("Solenoides inicializados");
    #endif
  }
  
  void displayCharacter(uint8_t brailleByte, unsigned long charDuration = DEFAULT_DURATION) {
    if (charDuration < MIN_DURATION) charDuration = MIN_DURATION;
    if (charDuration > MAX_DURATION) charDuration = MAX_DURATION;
    
    // Decodificar byte Braille (cada bit representa un punto)
    for (int i = 0; i < 6; i++) {
      bool pointActive = (brailleByte >> i) & 0x01;
      activatePoint(i, pointActive, charDuration);
    }
    
    Serial.printf("Mostrando carácter Braille: 0x%02X, Duración: %lums\n", 
                  brailleByte, charDuration);
    printPointsState();
  }
  
  void activatePoint(int pointIndex, bool active, unsigned long pointDuration = DEFAULT_DURATION) {
    if (pointIndex < 0 || pointIndex > 5) return;
    
    currentPoints[pointIndex] = active;
    activationTime[pointIndex] = millis();
    duration[pointIndex] = pointDuration;
    
    #ifdef USE_SERVOS
      // Control de servomotores
      if (active) {
        servos[pointIndex].write(SERVO_ANGLE_UP);
      } else {
        servos[pointIndex].write(SERVO_ANGLE_DOWN);
      }
    #else
      // Control de solenoides (LOW = activo para solenoides normalmente abiertos)
      digitalWrite(pins[pointIndex], active ? HIGH : LOW);
    #endif
  }
  
  void update() {
    if (isPaused) return;
    
    unsigned long currentTime = millis();
    
    // Desactivar puntos cuyo tiempo haya expirado
    for (int i = 0; i < 6; i++) {
      if (currentPoints[i] && (currentTime - activationTime[i] >= duration[i])) {
        #ifdef USE_SERVOS
          servos[i].write(SERVO_ANGLE_DOWN);
        #else
          digitalWrite(pins[i], LOW);
        #endif
        currentPoints[i] = false;
      }
    }
  }
  
  void play() {
    isPlaying = true;
    isPaused = false;
    Serial.println("Reproducción iniciada/reanudada");
  }
  
  void pause() {
    isPaused = true;
    Serial.println("Reproducción pausada");
  }
  
  void stop() {
    isPlaying = false;
    isPaused = false;
    clearAllPoints();
    Serial.println("Reproducción detenida");
  }
  
  void clearAllPoints() {
    for (int i = 0; i < 6; i++) {
      #ifdef USE_SERVOS
        servos[i].write(SERVO_ANGLE_DOWN);
      #else
        digitalWrite(pins[i], LOW);
      #endif
      currentPoints[i] = false;
    }
    Serial.println("Todos los puntos desactivados");
  }
  
  void printPointsState() {
    Serial.print("Estado puntos: ");
    for (int i = 0; i < 6; i++) {
      Serial.print(currentPoints[i] ? "1" : "0");
    }
    Serial.println();
  }
  
  bool getPointState(int pointIndex) {
    if (pointIndex < 0 || pointIndex > 5) return false;
    return currentPoints[pointIndex];
  }
};

#endif