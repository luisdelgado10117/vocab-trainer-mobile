import 'package:flutter/material.dart';

import '../services/api_service.dart';

/// Muestra la racha de estudio, tarjetas dominadas, y actividad del día.
class StatsScreen extends StatefulWidget {
  final String token;

  const StatsScreen({super.key, required this.token});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await ApiService.getStats(widget.token);
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi progreso')),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _stats == null) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  _errorMessage ?? 'Error desconocido',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final stats = _stats!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStreakBanner(
          current: stats['current_streak'] as int,
          longest: stats['longest_streak'] as int,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.style,
                color: Colors.blue,
                value: '${stats['total_cards']}',
                label: 'Palabras totales',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.workspace_premium,
                color: Colors.amber,
                value: '${stats['mastered_cards']}',
                label: 'Dominadas',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.check_circle,
          color: Colors.green,
          value: '${stats['cards_reviewed_today']}',
          label: 'Repasadas hoy',
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStreakBanner({required int current, required int longest}) {
    final hasStreak = current > 0;

    return Card(
      color: hasStreak ? Colors.deepOrange.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 56,
              color: hasStreak ? Colors.deepOrange : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              '$current ${current == 1 ? "día" : "días"} seguidos',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              hasStreak ? '¡Sigue así!' : 'Repasa hoy para empezar una racha',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (longest > current) ...[
              const SizedBox(height: 12),
              Text(
                'Tu racha más larga: $longest ${longest == 1 ? "día" : "días"}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    bool fullWidth = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
