import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _erreur;

  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _erreur = 'Les mots de passe ne correspondent pas.');
      return;
    }
    setState(() {
      _loading = true;
      _erreur = null;
    });
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailCtrl.text.trim(),
          'username': _usernameCtrl.text.trim(),
          'first_name': _firstCtrl.text.trim(),
          'last_name': _lastCtrl.text.trim(),
          'telephone': _telCtrl.text.trim(),
          'password': _passCtrl.text,
          'role': 'CITOYEN',
        }),
      );
      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès ! Connectez-vous.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        final data = jsonDecode(response.body);
        String msg = '';
        data.forEach((key, value) {
          msg += '$key : ${value is List ? value.join(', ') : value}\n';
        });
        setState(() => _erreur = msg.trim());
      }
    } catch (e) {
      setState(() => _erreur = 'Erreur de connexion au serveur.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF006743),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006743).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_add_outlined,
                            color: Color(0xFF006743), size: 48),
                      ),
                      const SizedBox(height: 12),
                      const Text('Créer un compte',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006743))),
                      const Text('Ministère de la Justice',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 24),

                      // Prénom + Nom sur la même ligne
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Prénom *',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lastCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nom *',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requis' : null,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Champ obligatoire';
                          if (!v.contains('@')) return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Username
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nom d'utilisateur *",
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Champ obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Téléphone
                      TextFormField(
                        controller: _telCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Téléphone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Mot de passe
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure1,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe *',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure1
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscure1 = !_obscure1),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Champ obligatoire';
                          if (v.length < 6) return 'Minimum 6 caractères';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirmer mot de passe
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscure2,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe *',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure2
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscure2 = !_obscure2),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Champ obligatoire'
                            : null,
                      ),

                      // Message d'erreur
                      if (_erreur != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_erreur!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Bouton S'inscrire
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text("S'inscrire",
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lien vers login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Déjà un compte ? ',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            ),
                            child: const Text('Se connecter',
                                style: TextStyle(
                                    color: Color(0xFF006743),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
