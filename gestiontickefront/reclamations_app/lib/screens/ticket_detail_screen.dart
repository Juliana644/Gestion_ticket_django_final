import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';

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
  String _userRole = '';

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
    setState(() => _userRole = prefs.getString('user_role') ?? '');
  }

  Color _statColor(String s) {
    switch (s) {
      case 'OUVERT':
        return Colors.blue.shade700;
      case 'EN_COURS':
        return Colors.orange.shade700;
      case 'RESOLU':
        return Colors.green.shade700;
      case 'CLOS':
        return Colors.grey.shade600;
      default:
        return Colors.black;
    }
  }

  Future<void> _changerStatut(Ticket ticket) async {
    final statuts = ['OUVERT', 'EN_COURS', 'RESOLU', 'CLOS'];
    final choisi = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Changer le statut'),
        children: statuts
            .map((s) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, s),
                  child: Row(children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: _statColor(s), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Text(s.replaceAll('_', ' ')),
                  ]),
                ))
            .toList(),
      ),
    );
    if (choisi == null) return;
    await _service.changerStatut(ticket.id, choisi);
    _charger();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut mis à jour : $choisi'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _ajouterCommentaire(Ticket ticket) async {
    if (_commentCtrl.text.trim().isEmpty) return;
    await _service.commenter(ticket.id, _commentCtrl.text.trim());
    _commentCtrl.clear();
    _charger();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final ticket = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte principale
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(ticket.titre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    _statColor(ticket.statut).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _statColor(ticket.statut)
                                        .withOpacity(0.5)),
                              ),
                              child: Text(
                                ticket.statut.replaceAll('_', ' '),
                                style: TextStyle(
                                    color: _statColor(ticket.statut),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                            icon: Icons.category_outlined,
                            label: 'Type',
                            value: ticket.typeTicket),
                        _InfoRow(
                            icon: Icons.flag_outlined,
                            label: 'Priorité',
                            value: ticket.priorite),
                        _InfoRow(
                            icon: Icons.person_outline,
                            label: 'Auteur',
                            value: ticket.auteurNom),
                        if (ticket.assigneA != null)
                          _InfoRow(
                              icon: Icons.engineering_outlined,
                              label: 'Assigné à',
                              value: ticket.assigneA!),
                        _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Créé le',
                            value: ticket.dateCreation.substring(0, 10)),
                        const SizedBox(height: 10),
                        const Text('Description',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(ticket.description,
                            style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                ),
                // Bouton changer statut (Tech/Admin seulement)
                if (_userRole == 'TECHNICIEN' || _userRole == 'ADMIN') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _changerStatut(ticket),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Changer le statut'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF006743),
                        side: const BorderSide(color: Color(0xFF006743)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                // Commentaires
                const SizedBox(height: 20),
                const Text('Commentaires',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                // Ajouter commentaire
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Ajouter un commentaire...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            maxLines: null,
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.send, color: Color(0xFF006743)),
                          onPressed: () => _ajouterCommentaire(ticket),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text('$label : ',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
