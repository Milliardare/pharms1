import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifierNumeroWhatsAppPage extends StatefulWidget {
  @override
  _ModifierNumeroWhatsAppPageState createState() => _ModifierNumeroWhatsAppPageState();
}

class _ModifierNumeroWhatsAppPageState extends State<ModifierNumeroWhatsAppPage> {
  final TextEditingController _numeroController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerNumeroActuel();
  }

  Future<void> _chargerNumeroActuel() async {
    final doc = await FirebaseFirestore.instance.collection('config').doc('whatsapp').get();
    if (doc.exists) {
      _numeroController.text = doc['numero'] ?? '';
    }
  }

  Future<void> _enregistrerNumero() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('config').doc('whatsapp').set({
        'numero': _numeroController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Numéro WhatsApp mis à jour")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le numéro WhatsApp'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _numeroController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nouveau numéro WhatsApp',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _enregistrerNumero,
              icon: Icon(Icons.save),
              label: Text(_isLoading ? 'Enregistrement...' : 'Enregistrer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                minimumSize: Size(double.infinity, 48),
              ),
            )
          ],
        ),
      ),
    );
  }
}
