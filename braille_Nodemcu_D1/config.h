#ifndef CONFIG_H
#define CONFIG_H

// Configuración de pines para los 6 puntos Braille
#define PIN_POINT_1 D1  // GPIO5
#define PIN_POINT_2 D2  // GPIO4
#define PIN_POINT_3 D3  // GPIO0
#define PIN_POINT_4 D5  // GPIO14
#define PIN_POINT_5 D6  // GPIO12
#define PIN_POINT_7 D7  // GPIO13

// Si usas servomotores en lugar de solenoides
// #define USE_SERVOS

#ifdef USE_SERVOS
  #include <Servo.h>
  #define SERVO_ANGLE_UP 90
  #define SERVO_ANGLE_DOWN 0
#endif

// Configuración BLE
#define SERVICE_UUID "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
#define CHARACTERISTIC_UUID_RX "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
#define CHARACTERISTIC_UUID_TX "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

// Tiempos de configuración
#define DEFAULT_DURATION 500
#define MIN_DURATION 100
#define MAX_DURATION 5000

#endif