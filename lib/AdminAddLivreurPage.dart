import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddLivreurPage extends StatefulWidget {
  @override
  _AdminAddLivreurPageState createState() => _AdminAddLivreurPageState();
}

class _AdminAddLivreurPageState extends State<AdminAddLivreurPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  final _name  = TextEditingController();
  final _phone = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;


  @override
  void dispose() {
    _email.dispose(); _pass.dispose(); _name.dispose(); _phone.dispose();
    super.dispose();
  }

  Future<void> _createLivreur() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // 1 – Auth
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _email.text.trim(),
              password: _pass.text.trim());

      // 2 – Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'nom'       : _name.text.trim(),
        'telephone' : _phone.text.trim(),
        'role'      : 'livreur',
        'createdAt' : FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context); // retour, ou snackbar succès
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Erreur')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un livreur')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (v) => v!.isEmpty ? 'Nom requis' : null,
              ),
              TextFormField(
                controller: _phone,
                decoration: InputDecoration(labelText: 'Téléphone'),
              ),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (v) => v!.contains('@') ? null : 'Email invalide',
              ),
              TextFormField(
                controller: _pass,
               obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                 suffixIcon: IconButton(
                 icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                 _obscurePassword = !_obscurePassword;
        });
      },
    ),
    border: OutlineInputBorder(),
  ),
  validator: (v) => v!.length < 6 ? '≥ 6 caractères' : null,
                // controller: _pass,
                // decoration: InputDecoration(labelText: 'Mot de passe'),
                // obscureText: true,
                // validator: (v) => v!.length < 6 ? '≥ 6 caractères' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _createLivreur,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Créer le compte livreur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
