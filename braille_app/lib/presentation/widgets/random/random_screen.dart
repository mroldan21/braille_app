// lib/presentation/widgets/random/random_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/braille_service.dart';
import '../../../presentation/providers/ble_provider.dart';
import '../../../presentation/providers/braille_provider.dart';
import '../../../presentation/providers/settings_provider.dart';
import '../../../presentation/widgets/common/braille_display.dart';

class RandomScreen extends StatefulWidget {
  const RandomScreen({super.key});

  @override
  State<RandomScreen> createState() => _RandomScreenState();
}

class _RandomScreenState extends State<RandomScreen> {
  CharCategory _selectedCategory = CharCategory.mixed;
  bool _isSending = false;

  Future<void> _generateAndSend() async {
    setState(() => _isSending = true);

    final brailleProvider = Provider.of<BrailleProvider>(context, listen: false);
    final bleProvider = Provider.of<BLEProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    brailleProvider.generateRandomChar(_selectedCategory);

    final success = await bleProvider.sendBrailleCharacter(
      brailleProvider.currentCharacter!,
      settingsProvider.settings.characterDelay,
    );

    // Solo proceder si el widget sigue montado
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Carácter ${brailleProvider.lastRandomChar} enviado'),
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
          
          // Último carácter generado
          if (brailleProvider.lastRandomChar.isNotEmpty) ...[
            Text(
              'Último carácter: ${brailleProvider.lastRandomChar}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
          ],
          
          // Selector de categoría
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo de carácter:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildCategoryChip(CharCategory.letters, 'Letras'),
                      _buildCategoryChip(CharCategory.numbers, 'Números'),
                      _buildCategoryChip(CharCategory.mixed, 'Mixto'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => brailleProvider.generateRandomChar(_selectedCategory),
                  icon: const Icon(Icons.casino),
                  label: const Text('Generar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !bleProvider.isConnected || _isSending
                      ? null
                      : _generateAndSend,
                  icon: _isSending 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bluetooth),
                  label: Text(_isSending ? 'Enviando...' : 'Enviar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(CharCategory category, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedCategory == category,
      onSelected: (selected) {
        setState(() => _selectedCategory = category);
      },
    );
  }
}