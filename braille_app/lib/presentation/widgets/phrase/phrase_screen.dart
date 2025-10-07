// lib/presentation/widgets/phrase/phrase_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/ble_provider.dart';
import '../../../presentation/providers/braille_provider.dart';
import '../../../presentation/providers/settings_provider.dart';
import '../../../presentation/widgets/common/braille_display.dart';

class PhraseScreen extends StatefulWidget {
  const PhraseScreen({super.key});

  @override
  State<PhraseScreen> createState() => _PhraseScreenState();
}

class _PhraseScreenState extends State<PhraseScreen> {
  final TextEditingController _phraseController = TextEditingController();
  bool _isPlaying = false;
  Timer? _playbackTimer;

  @override
  void dispose() {
    _phraseController.dispose();
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _startPlayback() {
    final brailleProvider = Provider.of<BrailleProvider>(context, listen: false);
    
    if (_phraseController.text.isEmpty) return;
    
    brailleProvider.setPhrase(_phraseController.text);
    brailleProvider.startPhrasePlayback();
    
    setState(() => _isPlaying = true);
    
    // Iniciar reproducción secuencial
    _playCharacterSequence();
  }

  void _playCharacterSequence() async {
    final brailleProvider = Provider.of<BrailleProvider>(context, listen: false);
    final bleProvider = Provider.of<BLEProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    while (_isPlaying && brailleProvider.isPlayingPhrase) {
      final nextChar = brailleProvider.getNextPhraseCharacter();
      if (nextChar == null) break;
      
      await bleProvider.sendBrailleCharacter(
        nextChar,
        settingsProvider.settings.characterDelay,
      );
      
      // Esperar antes del siguiente carácter
      await Future.delayed(
        Duration(milliseconds: settingsProvider.settings.characterDelay),
      );
      
      if (!_isPlaying) break;
    }
    
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  void _pausePlayback() {
    final brailleProvider = Provider.of<BrailleProvider>(context, listen: false);
    brailleProvider.pausePhrasePlayback();
    setState(() => _isPlaying = false);
  }

  void _stopPlayback() {
    final brailleProvider = Provider.of<BrailleProvider>(context, listen: false);
    brailleProvider.stopPhrasePlayback();
    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final brailleProvider = Provider.of<BrailleProvider>(context);
    final bleProvider = Provider.of<BLEProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    final duration = brailleProvider.calculatePhraseDuration(
      settingsProvider.settings.characterDelay,
    );
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Display Braille actual
          BrailleDisplay(
            character: brailleProvider.currentCharacter,
            size: 120,
          ),
          const SizedBox(height: 16),
          
          // Barra de progreso
          if (brailleProvider.currentPhrase.isNotEmpty) ...[
            LinearProgressIndicator(
              value: brailleProvider.getPhraseProgress(),
              backgroundColor: Colors.grey[300],
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              '${brailleProvider.currentPhraseIndex}/${brailleProvider.currentPhrase.length} '
              'caracteres (${(duration / 1000).toStringAsFixed(1)}s)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
          ],
          
          // Área de texto para frase
          Expanded(
            child: TextField(
              controller: _phraseController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                labelText: 'Ingresa una frase',
                hintText: 'Escribe aquí la frase a reproducir...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Controles de reproducción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _phraseController.text.isEmpty || 
                            !bleProvider.isConnected ||
                            _isPlaying
                      ? null
                      : _startPlayback,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Reproducir'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isPlaying ? _pausePlayback : null,
                icon: const Icon(Icons.pause),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              IconButton(
                onPressed: _isPlaying || brailleProvider.currentPhrase.isNotEmpty
                    ? _stopPlayback
                    : null,
                icon: const Icon(Icons.stop),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}