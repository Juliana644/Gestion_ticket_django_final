import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});
  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _service = TicketService();
  final _commentCtrl = TextEditingController();
  late Future<Ticket> _futureTicket;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _charger();
    _loadRole();
  }

  void _charger() {
    setState(() {
      _futureTicket = _service.getTicket(widget.ticketId);
    });
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _role = prefs.getString('user_role') ?? 'CITOYEN');
  }

  Future<void> _changerStatut(String statut) async {
    await _service.changerStatut(widget.ticketId, statut);
    _charger();
  }

  Future<void> _commenter() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    await _service.commenter(widget.ticketId, _commentCtrl.text.trim());
    _commentCtrl.clear();
    _charger();
  }

  Color _statColor(String s) {
    switch (s) {
      case 'OUVERT':
        return Colors.blue;
      case 'EN_COURS':
        return Colors.orange;
      case 'RESOLU':
        return Colors.green;
      case 'CLOS':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du ticket'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Ticket>(
        future: _futureTicket,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final ticket = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête ticket
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(ticket.titre,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statColor(ticket.statut).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: _statColor(ticket.statut)),
                            ),
                            child: Text(ticket.statut,
                                style: TextStyle(
                                    color: _statColor(ticket.statut),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]),
                        const Divider(height: 20),
                        Text(ticket.description,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          _Chip(Icons.category, ticket.typeTicket),
                          _Chip(Icons.flag, ticket.priorite),
                          _Chip(Icons.person, ticket.auteurNom),
                          if (ticket.assigneA != null)
                            _Chip(Icons.engineering, ticket.assigneA!),
                        ]),
                      ],
                    ),
                  ),
                ),
                // Changer statut (technicien/admin)
                if (_role == 'TECHNICIEN' || _role == 'ADMIN') ...[
                  const SizedBox(height: 16),
                  const Text('Changer le statut',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    for (final s in ['OUVERT', 'EN_COURS', 'RESOLU', 'CLOS'])
                      ElevatedButton(
                        onPressed:
                            ticket.statut == s ? null : () => _changerStatut(s),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _statColor(s),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(s),
                      ),
                  ]),
                ],
                // Historique
                if (ticket.historique.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Historique',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  ...ticket.historique.map((h) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.history, size: 18),
                        title: Text(
                            '${h["ancien_statut"]} → ${h["nouveau_statut"]}'),
                        subtitle: Text(h["modifie_par"]?["email"] ?? ''),
                      )),
                ],
                // Commentaires
                const SizedBox(height: 16),
                const Text('Commentaires',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                if (ticket.commentaires.isEmpty)
                  const Text('Aucun commentaire.',
                      style: TextStyle(color: Colors.grey)),
                ...ticket.commentaires.map((c) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                            child: Icon(Icons.person, size: 16)),
                        title: Text(c["contenu"] ?? ''),
                        subtitle: Text(c["auteur"]?["email"] ?? '',
                            style: const TextStyle(fontSize: 11)),
                      ),
                    )),
                // Ajouter commentaire
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF006743)),
                    onPressed: _commenter,
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
