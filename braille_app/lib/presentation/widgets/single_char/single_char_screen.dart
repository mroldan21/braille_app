// lib/presentation/widgets/single_char/single_char_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/ble_provider.dart';
import '../../../presentation/providers/braille_provider.dart';
import '../../../presentation/providers/settings_provider.dart';
import '../../../presentation/widgets/common/braille_display.dart';

class SingleCharScreen extends StatefulWidget {
  const SingleCharScreen({super.key});

  @override
  State<SingleCharScreen> createState() => _SingleCharScreenState();
}

class _SingleCharScreenState extends State<SingleCharScreen> {
  final TextEditingController _charController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _charController.dispose();
    super.dispose();
  }

  Future<void> _sendCharacter() async {
    if (_charController.text.isEmpty) return;

    final brailleProvider = Provider.of<BrailleProvider>(context, listen: false);
    final bleProvider = Provider.of<BLEProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    setState(() => _isSending = true);

    // Convertir y mostrar el carácter
    brailleProvider.setCharacter(_charController.text);

    // Operación async - enviar al dispositivo
    final success = await bleProvider.sendBrailleCharacter(
      brailleProvider.currentCharacter!,
      settingsProvider.settings.characterDelay,
    );

    // VERIFICAR si el widget sigue montado antes de usar context
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Carácter ${_charController.text} enviado'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar carácter'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final brailleProvider = Provider.of<BrailleProvider>(context);
    final bleProvider = Provider.of<BLEProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Display Braille
          BrailleDisplay(
            character: brailleProvider.currentCharacter,
            size: 150,
          ),
          const SizedBox(height: 32),
          
          // Input de carácter
          TextField(
            controller: _charController,
            maxLength: 1,
            decoration: InputDecoration(
              labelText: 'Ingresa un carácter',
              hintText: 'Ej: A, 1, ,',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _charController.clear(),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                brailleProvider.setCharacter(value);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Botón enviar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _charController.text.isEmpty || 
                        !bleProvider.isConnected || 
                        _isSending
                  ? null
                  : _sendCharacter,
              icon: _isSending 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bluetooth),
              label: Text(_isSending ? 'Enviando...' : 'Enviar Carácter'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Información de caracteres soportados
          ExpansionTile(
            title: const Text('Caracteres soportados'),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: brailleProvider.getSupportedCharacters().map((char) {
                  return ChoiceChip(
                    label: Text(char == ' ' ? 'ESPACIO' : char),
                    selected: false,
                    onSelected: (_) {
                      _charController.text = char;
                      brailleProvider.setCharacter(char);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}