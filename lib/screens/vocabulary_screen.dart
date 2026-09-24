import 'package:flutter/material.dart';

import '../services/api_service.dart';

/// Muestra todas tus palabras organizadas por verbo (cada verbo es un
/// bloque expandible con sus 3 formas), en vez de una lista plana.
class VocabularyScreen extends StatefulWidget {
  final String token;

  const VocabularyScreen({super.key, required this.token});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _ungrouped = [];
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
      final data = await ApiService.getGroupedCards(widget.token);
      setState(() {
        _groups = (data['groups'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        _ungrouped = (data['ungrouped'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
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

  /// Una tarjeta se considera "dominada" con la misma convención que usa
  /// el backend: 21 días o más de intervalo (tarjeta "madura" en Anki).
  bool _isMastered(Map<String, dynamic> form) =>
      (form['interval'] as int) >= 21;

  bool _isDueToday(Map<String, dynamic> form) {
    final due = DateTime.parse(form['due_date'] as String);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return !due.isAfter(todayOnly);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi vocabulario')),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ],
      );
    }

    if (_groups.isEmpty && _ungrouped.isEmpty) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Todavía no tienes palabras.\nImporta el vocabulario inicial desde la pantalla de repaso.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView(
      children: [
        for (final group in _groups) _buildGroupTile(group),
        if (_ungrouped.isNotEmpty) _buildUngroupedSection(),
      ],
    );
  }

  Widget _buildGroupTile(Map<String, dynamic> group) {
    final forms = (group['forms'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final masteredCount = forms.where(_isMastered).length;

    return ExpansionTile(
      title: Text(
        (group['group'] as String).toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('$masteredCount de ${forms.length} formas dominadas'),
      children: forms.map(_buildFormTile).toList(),
    );
  }

  Widget _buildUngroupedSection() {
    return ExpansionTile(
      title: const Text(
        'Otras palabras',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: _ungrouped.map(_buildFormTile).toList(),
    );
  }

  Widget _buildFormTile(Map<String, dynamic> form) {
    final mastered = _isMastered(form);
    final dueToday = _isDueToday(form);
    final tense = form['tense'] as String?;

    IconData icon;
    Color color;
    String status;

    if (mastered) {
      icon = Icons.star;
      color = Colors.amber;
      status = 'Dominada';
    } else if (dueToday) {
      icon = Icons.schedule;
      color = Colors.orange;
      status = 'Pendiente hoy';
    } else {
      icon = Icons.check_circle_outline;
      color = Colors.green;
      status = 'Próx: ${form['due_date']}';
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(form['word'] as String),
      subtitle: Text(
        tense != null
            ? '${form['translation']}  ·  $tense'
            : form['translation'] as String,
      ),
      trailing: Text(status, style: const TextStyle(fontSize: 12)),
    );
  }
}
