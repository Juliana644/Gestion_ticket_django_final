import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';
import 'create_ticket_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _service = TicketService();
  late Future<List<Ticket>> _futureTickets;
  String? _filtreStatut;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _charger() {
    setState(() {
      _futureTickets = _service.listerTickets(statut: _filtreStatut);
    });
  }

  List<Ticket> _filtrer(List<Ticket> tickets) {
    if (_searchQuery.isEmpty) return tickets;
    return tickets
        .where((t) =>
            t.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Mes tickets'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer par statut',
            onSelected: (val) {
              setState(() => _filtreStatut = val);
              _charger();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Tous')),
              const PopupMenuItem(value: 'OUVERT', child: Text('Ouvert')),
              const PopupMenuItem(value: 'EN_COURS', child: Text('En cours')),
              const PopupMenuItem(value: 'RESOLU', child: Text('Résolu')),
              const PopupMenuItem(value: 'CLOS', child: Text('Clos')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher un ticket...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          // Filtre actif
          if (_filtreStatut != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Chip(
                    label: Text('Statut: $_filtreStatut',
                        style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      setState(() => _filtreStatut = null);
                      _charger();
                    },
                    backgroundColor: const Color(0xFF006743).withOpacity(0.1),
                  ),
                ],
              ),
            ),
          // Liste
          Expanded(
            child: FutureBuilder<List<Ticket>>(
              future: _futureTickets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('Erreur: ${snapshot.error}',
                            textAlign: TextAlign.center),
                        TextButton(
                            onPressed: _charger,
                            child: const Text('Réessayer')),
                      ],
                    ),
                  );
                }
                final tickets = _filtrer(snapshot.data ?? []);
                if (tickets.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 56, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Aucun ticket trouvé',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _charger(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: tickets.length,
                    itemBuilder: (_, i) => TicketCard(
                      ticket: tickets[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TicketDetailScreen(ticketId: tickets[i].id),
                        ),
                      ).then((_) => _charger()),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
        ).then((_) => _charger()),
        label: const Text('Nouveau ticket'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
      ),
    );
  }
}
