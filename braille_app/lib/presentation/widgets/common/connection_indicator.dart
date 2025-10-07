// lib/presentation/widgets/common/connection_indicator.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/ble_provider.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BLEProvider>(context);
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bleProvider.isConnected ? Colors.green : Colors.red,
            boxShadow: [
              BoxShadow(
                color: bleProvider.isConnected 
                    ? Colors.green.withOpacity(0.5)
                    : Colors.red.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          bleProvider.isConnected ? 'Conectado' : 'Desconectado',
          style: TextStyle(
            color: bleProvider.isConnected ? Colors.green : Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}