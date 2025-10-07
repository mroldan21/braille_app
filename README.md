# **Sistema Braille Controlado por Bluetooth**

## **📋 Descripción del Proyecto**

Sistema completo para representar caracteres Braille mediante dispositivos mecatrónicos (servomotores o solenoides) controlados desde una aplicación Android vía Bluetooth Low Energy (BLE).

### **🏗️ Arquitectura del Sistema**
```
Aplicación Flutter (Android) ←BLE→ ESP8266/ESP32 ←→ Servomotores/Solenoides
```

---

## **📱 Aplicación Flutter**

### **Requisitos**
- Flutter SDK 3.0+
- Android 8.0+ (API 26+)
- Bluetooth 4.2+ (BLE)

### **Instalación**
1. **Clonar/Descargar** el proyecto Flutter
2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```
3. **Configurar archivo .env** en la raíz del proyecto:
   ```env
   BRAILLE_SERVICE_UUID=6e400001-b5a3-f393-e0a9-e50e24dcca9e
   TX_CHARACTERISTIC_UUID=6e400002-b5a3-f393-e0a9-e50e24dcca9e
   RX_CHARACTERISTIC_UUID=6e400003-b5a3-f393-e0a9-e50e24dcca9e
   ```

4. **Ejecutar en dispositivo Android:**
   ```bash
   flutter run
   ```

### **Funcionalidades de la App**
- ✅ **Carácter Individual**: Ingreso y envío de caracteres individuales
- ✅ **Generador Aleatorio**: Generación de caracteres aleatorios por categoría
- ✅ **Modo Frase**: Reproducción secuencial de frases completas
- ✅ **Configuración**: Ajuste de timing, conexión BLE y preferencias
- ✅ **Visualización Braille**: Representación visual del carácter actual

---

## **⚙️ Firmware ESP8266/ESP32**

### **Hardware Compatible**
- ✅ NodeMCU ESP8266 (D1 Mini)
- ✅ ESP32 DevKit
- ✅ Wemos D1 R2

### **📦 Librerías Requeridas**

#### **Para ESP8266:**
```cpp
// En Arduino IDE incluir:
#include <ESP8266WiFi.h>
#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>

// El ESP8266 core ya incluye soporte BLE
```

#### **Para ESP32:**
```cpp
// En Arduino IDE incluir:
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Instalar via Library Manager: "ESP32 BLE Arduino"
```

### **🔧 Configuración de Pines**

#### **Opción A: Para Solenoides (Salidas Digitales)**
```cpp
#define PIN_POINT_1 5   // D1
#define PIN_POINT_2 4   // D2  
#define PIN_POINT_3 0   // D3
#define PIN_POINT_4 14  // D5
#define PIN_POINT_5 12  // D6
#define PIN_POINT_6 13  // D7
```

#### **Opción B: Para Servomotores**
```cpp
#define USE_SERVOS  // Descomentar para usar servomotores

#define PIN_POINT_1 5   // D1
#define PIN_POINT_2 4   // D2
#define PIN_POINT_3 0   // D3  
#define PIN_POINT_4 14  // D5
#define PIN_POINT_5 12  // D6
#define PIN_POINT_6 13  // D7

#define SERVO_ANGLE_UP 90    // Ángulo para punto activo
#define SERVO_ANGLE_DOWN 0   // Ángulo para punto inactivo
```

### **📥 Instalación del Firmware**

1. **Instalar Arduino IDE**
2. **Agregar soporte para ESP8266/ESP32:**
   - File → Preferences → Additional Boards Manager URLs:
   - ESP8266: `http://arduino.esp8266.com/stable/package_esp8266com_index.json`
   - ESP32: `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`

3. **Instalar Boards:**
   - Tools → Board → Boards Manager
   - Buscar "ESP8266" o "ESP32" e instalar

4. **Configurar Board:**
   - **Board**: "NodeMCU 1.0 (ESP-12E Module)" o "ESP32 Dev Module"
   - **Upload Speed**: "115200"
   - **Flash Size**: "4MB (FS:2MB OTA:~1019KB)"
   - **Port**: Seleccionar puerto COM correcto

5. **Cargar el Sketch:**
   - Abrir `braille_esp8266.ino`
   - Compilar y subir al dispositivo

### **🔌 Diagrama de Conexiones**

```
ESP8266/ESP32 → Actuadores Braille
     D1 (GPIO5)  → Punto 1 (Superior Izquierdo)
     D2 (GPIO4)  → Punto 2 (Medio Izquierdo)  
     D3 (GPIO0)  → Punto 3 (Inferior Izquierdo)
     D5 (GPIO14) → Punto 4 (Superior Derecho)
     D6 (GPIO12) → Punto 5 (Medio Derecho)
     D7 (GPIO13) → Punto 6 (Inferior Derecho)
     GND         → Tierra común
     3.3V/5V     → Alimentación actuadores
```

### **⚡ Alimentación**
- **ESP8266/ESP32**: 5V via USB o fuente externa
- **Solenoides**: Fuente externa 5V-12V según especificaciones
- **Servomotores**: Fuente externa 5V-6V (no alimentar via USB)

---

## **🔗 Protocolo de Comunicación BLE**

### **Servicio UUID**
```cpp
#define SERVICE_UUID "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
#define CHARACTERISTIC_UUID_RX "6e400002-b5a3-f393-e0a9-e50e24dcca9e" 
#define CHARACTERISTIC_UUID_TX "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
```

### **Formato de Comandos**
```
[HEADER][COMMAND_TYPE][DATA][DURATION_HIGH][DURATION_LOW][CHECKSUM]
0xAA    0x01          0x3F   0x01          0xF4         0xXX

- HEADER: 0xAA (1 byte)
- COMMAND_TYPE: 
  0x01 = Carácter Braille
  0x02 = Control (play/pause/stop)
- DATA: Byte Braille (6 bits) + 2 bits reservados
- DURATION: uint16 (ms)
- CHECKSUM: XOR de todos los bytes anteriores
```

### **Comandos de Control**
```cpp
0x01 // Play - Iniciar reproducción
0x02 // Pause - Pausar reproducción  
0x03 // Stop - Detener y limpiar todos los puntos
```

---

## **🎯 Caracteres Braille Soportados**

### **Letras (a-z)**
```
a: 100000    b: 110000    c: 100100
d: 100110    e: 100010    f: 110100
... (patrón completo implementado)
```

### **Números (0-9)**
- Prefijo numérico + letras a-j
- Ej: 1 = ⠁ (100000), 2 = ⠃ (110000)

### **Símbolos**
```
Espacio: 000000    Coma: 010000     Punto: 010011
¡: 011010         ?: 010010        ;: 011000
```

---

## **🔧 Solución de Problemas**

### **Problemas Comunes de Conexión BLE**
1. **Dispositivo no aparece:**
   - Verificar que el ESP esté alimentado
   - Revisar que el sketch se cargó correctamente
   - Reiniciar el ESP

2. **Conexión falla:**
   - Verificar permisos de Bluetooth en Android
   - Acercar dispositivos
   - Reiniciar Bluetooth en el teléfono

3. **Comandos no llegan:**
   - Verificar UUIDs en app y firmware
   - Revisar checksum de comandos
   - Monitorear Serial Monitor a 115200 bauds

### **Debugging por Monitor Serial**
```cpp
// En Arduino IDE: Tools → Serial Monitor (115200 bauds)
[INFO] Dispositivo Braille iniciado
[INFO] Servicio BLE: Braille-ESP32
[INFO] Dispositivo conectado
[CMD] Carácter: 0x01, Duración: 500ms
```

---

## **📈 Mejoras Futuras**

- [ ] Soporte para contratos Braille
- [ ] Modo aprendizaje/tutorial
- [ ] Configuración de patrones personalizados
- [ ] Soporte para múltiples dispositivos simultáneos
- [ ] Logs de actividad y estadísticas

---

## **📄 Licencia**

Este proyecto está bajo licencia MIT. Ver archivo LICENSE para más detalles.

## Autor
Mg. Marcelo F. Roldán

## **👥 Contribuciones**

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

---

**¿Preguntas o problemas?** Abre un issue en el repositorio del proyecto.