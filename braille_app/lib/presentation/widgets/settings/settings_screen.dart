// lib/presentation/widgets/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/services/braille_service.dart';
import '../../../presentation/providers/ble_provider.dart';
import '../../../presentation/providers/settings_provider.dart';
import '../../../presentation/providers/braille_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final bleProvider = Provider.of<BLEProvider>(context);
    final brailleProvider = Provider.of<BrailleProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Configuración de Timing
            _buildTimingSettings(settingsProvider),
            const SizedBox(height: 24),
            
            // Configuración Bluetooth
            _buildBluetoothSettings(bleProvider, settingsProvider),
            const SizedBox(height: 24),
            
            // Configuración de Aplicación
            _buildAppSettings(settingsProvider),
            const SizedBox(height: 24),
            
            // Información y Acciones
            _buildInfoAndActions(brailleProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingSettings(SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de Timing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Delay entre caracteres
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delay entre caracteres:'),
                    Text('${settingsProvider.settings.characterDelay}ms'),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: settingsProvider.settings.characterDelay.toDouble(),
                  min: 100,
                  max: 5000,
                  divisions: 49,
                  label: '${settingsProvider.settings.characterDelay}ms',
                  onChanged: (value) {
                    settingsProvider.updateCharacterDelay(value.toInt());
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Velocidad: ${BrailleService().calculateWPM(settingsProvider.settings.characterDelay)} WPM',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Presets de velocidad
            const Text('Presets:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildPresetChip('Lento (1000ms)', 1000, settingsProvider),
                _buildPresetChip('Normal (500ms)', 500, settingsProvider),
                _buildPresetChip('Rápido (200ms)', 200, settingsProvider),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, int delay, SettingsProvider provider) {
    return ActionChip(
      label: Text(label),
      onPressed: () => provider.updateCharacterDelay(delay),
    );
  }

  Widget _buildBluetoothSettings(BLEProvider bleProvider, SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración Bluetooth',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Estado de conexión
            ListTile(
              leading: Icon(
                bleProvider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: bleProvider.isConnected ? Colors.green : Colors.grey,
              ),
              title: Text(
                bleProvider.isConnected ? 'Conectado' : 'Desconectado',
                style: TextStyle(
                  color: bleProvider.isConnected ? Colors.green : Colors.grey,
                ),
              ),
              subtitle: Text(
                bleProvider.isConnected 
                    ? 'Conectado a ${bleProvider.connectedDevice?.name ?? "dispositivo"}'
                    : 'No hay dispositivos conectados',
              ),
            ),
            
            // Dispositivos disponibles
            if (bleProvider.devices.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Dispositivos disponibles:'),
              const SizedBox(height: 8),
              ...bleProvider.devices.map((device) => ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(device.name),
                subtitle: Text('RSSI: ${device.rssi}'),
                trailing: bleProvider.isConnected && bleProvider.connectedDevice?.id == device.id
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () => bleProvider.connectToDevice(device),
              )),
            ],
            
            // Botones de acción Bluetooth
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: bleProvider.isScanning ? null : () => bleProvider.startScan(),
                    icon: const Icon(Icons.search),
                    label: Text(bleProvider.isScanning ? 'Escaneando...' : 'Buscar Dispositivos'),
                  ),
                ),
                const SizedBox(width: 8),
                if (bleProvider.isConnected)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => bleProvider.disconnect(),
                      icon: const Icon(Icons.link_off),
                      label: const Text('Desconectar'),
                    ),
                  ),
              ],
            ),
            
            // Opciones de conexión automática
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Conexión automática'),
              subtitle: const Text('Reconectar al último dispositivo al iniciar'),
              value: settingsProvider.settings.autoConnect,
              onChanged: settingsProvider.toggleAutoConnect,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettings(SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de Aplicación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Tema
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Tema'),
              trailing: DropdownButton<ThemeMode>(
                value: settingsProvider.settings.themeMode,
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    settingsProvider.updateThemeMode(newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Claro'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Oscuro'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Sistema'),
                  ),
                ],
              ),
            ),
            
            // Sonido
            SwitchListTile(
              title: const Text('Efectos de sonido'),
              value: settingsProvider.settings.soundEnabled,
              onChanged: settingsProvider.toggleSound,
            ),
            
            // Vibración
            SwitchListTile(
              title: const Text('Vibración'),
              value: settingsProvider.settings.vibrationEnabled,
              onChanged: settingsProvider.toggleVibration,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoAndActions(BrailleProvider brailleProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información y Acciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Caracteres soportados
            ExpansionTile(
              title: const Text('Caracteres soportados'),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: brailleProvider.getSupportedCharacters().map((char) {
                    return Chip(
                      label: Text(char == ' ' ? 'ESPACIO' : char),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            // Limpiar estado
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Limpiar estado actual'),
              onTap: () {
                brailleProvider.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estado limpiado')),
                );
              },
            ),
            
            // Solicitar permisos
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Verificar permisos'),
              onTap: _checkPermissions,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.bluetooth.request();
    final locationStatus = await Permission.location.request();

    // Solo mostrar snackbar si el widget sigue montado
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bluetooth: ${status.isGranted ? "Concedido" : "Denegado"}\n'
                'Ubicación: ${locationStatus.isGranted ? "Concedido" : "Denegado"}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}