import 'package:flutter/material.dart';
import '../services/ticket_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = TicketService();
  late Future<Map<String, dynamic>> _futureStats;

  @override
  void initState() {
    super.initState();
    _futureStats = _service.getStatistiques();
  }

  Color _statColor(String s) {
    switch (s) {
      case 'OUVERT':
        return Colors.blue.shade600;
      case 'EN_COURS':
        return Colors.orange.shade600;
      case 'RESOLU':
        return Colors.green.shade600;
      case 'CLOS':
        return Colors.grey.shade600;
      default:
        return Colors.purple.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          final total = data['total'] as int;
          final parStatut = data['par_statut'] as Map<String, dynamic>;
          final parTech = data['par_technicien'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: const Color(0xFF006743),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.confirmation_number,
                            color: Colors.white, size: 36),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$total',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold)),
                            const Text('tickets au total',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Par statut
                const Text('Répartition par statut',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ...parStatut.entries.map((e) {
                  final pct = total > 0 ? (e.value as int) / total : 0.0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                    color: _statColor(e.key),
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(e.key.replaceAll('_', ' '),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ),
                              Text('${e.value} tickets',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              color: _statColor(e.key),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                // Par technicien
                const Text('Charge par technicien',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                if (parTech.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucun ticket assigné pour le moment'),
                    ),
                  )
                else
                  ...parTech.map((t) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF006743).withOpacity(0.15),
                            child: const Icon(Icons.engineering,
                                color: Color(0xFF006743), size: 20),
                          ),
                          title: Text(
                              '${t["assigne_a__first_name"]} ${t["assigne_a__last_name"]}'),
                          trailing: Chip(
                            label: Text('${t["total"]} tickets',
                                style: const TextStyle(fontSize: 12)),
                            backgroundColor:
                                const Color(0xFF006743).withOpacity(0.1),
                          ),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}
