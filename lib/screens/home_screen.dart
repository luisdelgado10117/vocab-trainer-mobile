import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'vocabulary_screen.dart';

/// Muestra las tarjetas pendientes de repaso, una por una. Si no hay
/// ninguna (usuario nuevo), ofrece importar el vocabulario inicial.
class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _dueCards = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showTranslation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDueCards();
  }

  Future<void> _loadDueCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cards = await ApiService.getDueCards(widget.token);
      setState(() {
        _dueCards = cards;
        _showTranslation = false;
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

  Future<void> _importSeedPack() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final imported = await ApiService.importSeedPack(widget.token);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se agregaron $imported palabras nuevas')),
      );

      await _loadDueCards();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _submitReview(int quality) async {
    final currentCard = _dueCards.first;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.submitReview(
        widget.token,
        currentCard['id'] as int,
        quality,
      );

      setState(() {
        // Ya la calificamos: la quitamos de la lista local de pendientes
        // (el backend ya la movió a una fecha futura de repaso).
        _dueCards.removeAt(0);
        _showTranslation = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repaso de hoy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Ver mi vocabulario',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VocabularyScreen(token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _loadDueCards, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _dueCards.isEmpty) {
      return _buildMessageState(
        icon: Icons.error_outline,
        iconColor: Colors.red,
        message: _errorMessage!,
        showRetryButton: true,
      );
    }

    if (_dueCards.isEmpty) {
      return _buildMessageState(
        icon: Icons.celebration,
        iconColor: Colors.amber,
        message: '¡No tienes palabras pendientes por hoy!\n\nSi eres nuevo, importa el vocabulario inicial para empezar.',
        showImportButton: true,
      );
    }

    return _buildReviewCard();
  }

  Widget _buildMessageState({
    required IconData icon,
    required Color iconColor,
    required String message,
    bool showImportButton = false,
    bool showRetryButton = false,
  }) {
    return ListView(
      // ListView (no Column) para que RefreshIndicator (deslizar hacia
      // abajo para recargar) funcione incluso con poco contenido.
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Icon(icon, color: iconColor, size: 64),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              if (showImportButton)
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _importSeedPack,
                  icon: const Icon(Icons.download),
                  label: _isSubmitting
                      ? const Text('Importando...')
                      : const Text('Importar vocabulario inicial'),
                ),
              if (showRetryButton)
                ElevatedButton(
                  onPressed: _loadDueCards,
                  child: const Text('Reintentar'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard() {
    final card = _dueCards.first;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          '${_dueCards.length} palabra(s) pendiente(s)',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  card['word'] as String,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_showTranslation) ...[
                  const Divider(height: 32),
                  Text(
                    card['translation'] as String,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (!_showTranslation)
          ElevatedButton(
            onPressed: () => setState(() => _showTranslation = true),
            child: const Text('Mostrar traducción'),
          )
        else
          _buildQualityButtons(),
      ],
    );
  }

  Widget _buildQualityButtons() {
    const labels = ['Nada', 'Mal', 'Difícil', 'Bien', 'Fácil', 'Perfecto'];

    return Column(
      children: [
        const Text(
          '¿Qué tan bien la recordaste?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(6, (quality) {
            return ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitReview(quality),
              child: Text(
                '$quality\n${labels[quality]}',
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ],
    );
  }
}
