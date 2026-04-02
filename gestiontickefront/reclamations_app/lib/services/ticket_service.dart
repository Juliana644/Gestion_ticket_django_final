import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import 'auth_service.dart';

class TicketService {
  static const String _base = 'http://127.0.0.1:8000/api/tickets';
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Ticket>> listerTickets({String? statut, String? priorite}) async {
    String url = '$_base/';
    final params = <String, String>{};
    if (statut != null) params['statut'] = statut;
    if (priorite != null) params['priorite'] = priorite;
    if (params.isNotEmpty) {
      url += '?' + Uri(queryParameters: params).query;
    }
    final response = await http.get(Uri.parse(url), headers: await _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'] ?? data;
      return results.map((j) => Ticket.fromJson(j)).toList();
    }
    throw Exception('Impossible de charger les tickets.');
  }

  Future<Ticket> getTicket(int id) async {
    final response = await http.get(
      Uri.parse('$_base/$id/'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return Ticket.fromJson(jsonDecode(response.body));
    }
    throw Exception('Ticket introuvable.');
  }

  Future<Ticket> creerTicket(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_base/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Ticket.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erreur lors de la création du ticket.');
  }

  Future<void> changerStatut(int id, String nouveauStatut) async {
    await http.patch(
      Uri.parse('$_base/$id/changer_statut/'),
      headers: await _headers(),
      body: jsonEncode({'statut': nouveauStatut}),
    );
  }

  Future<void> commenter(int id, String contenu) async {
    await http.post(
      Uri.parse('$_base/$id/commenter/'),
      headers: await _headers(),
      body: jsonEncode({'contenu': contenu}),
    );
  }

  Future<void> assigner(int ticketId, int technicienId) async {
    await http.patch(
      Uri.parse('$_base/$ticketId/assigner/'),
      headers: await _headers(),
      body: jsonEncode({'technicien_id': technicienId}),
    );
  }

  Future<Map<String, dynamic>> getStatistiques() async {
    final response = await http.get(
      Uri.parse('$_base/statistiques/'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Impossible de charger les statistiques.');
  }
}
