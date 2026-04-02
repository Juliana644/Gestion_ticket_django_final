import 'package:flutter/material.dart';
import '../models/ticket.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  Color get _statColor {
    switch (ticket.statut) {
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

  Color get _prioColor {
    switch (ticket.priorite) {
      case 'CRITIQUE':
        return Colors.red.shade700;
      case 'HAUTE':
        return Colors.orange.shade700;
      case 'NORMALE':
        return Colors.blue.shade700;
      case 'BASSE':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  IconData get _typeIcon {
    switch (ticket.typeTicket) {
      case 'INCIDENT':
        return Icons.bug_report_outlined;
      case 'RECLAMATION':
        return Icons.warning_amber_outlined;
      case 'DEMANDE':
        return Icons.help_outline;
      default:
        return Icons.confirmation_number_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_typeIcon, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ticket.titre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _statColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      ticket.statut.replaceAll('_', ' '),
                      style: TextStyle(
                          color: _statColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.flag_outlined, size: 14, color: _prioColor),
                const SizedBox(width: 4),
                Text(ticket.priorite,
                    style: TextStyle(color: _prioColor, fontSize: 12)),
                const Spacer(),
                Icon(Icons.person_outline,
                    size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(ticket.auteurNom,
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
