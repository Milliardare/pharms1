import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPharmacyProfilePage extends StatefulWidget {
  @override
  _EditPharmacyProfilePageState createState() => _EditPharmacyProfilePageState();
}

class _EditPharmacyProfilePageState extends State<EditPharmacyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final openHourCtrl = TextEditingController();
  final closeHourCtrl = TextEditingController();

  File? _newImage;
  bool _loading = true;

  String? uid; // ← Stocke le UID du compte connecté

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _loadPharmacyData();
  }

  Future<void> _loadPharmacyData() async {
    final doc = await FirebaseFirestore.instance.collection('pharmacies').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      nameCtrl.text = data['name'] ?? '';
      phoneCtrl.text = data['phone'] ?? '';
      locationCtrl.text = data['location'] ?? '';
      openHourCtrl.text = data['openHour'] ?? '';
      closeHourCtrl.text = data['closeHour'] ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _newImage = File(picked.path));
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (uid == null) return;

    setState(() => _loading = true);

    final data = {
      'name': nameCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'location': locationCtrl.text.trim(),
      'openHour': openHourCtrl.text.trim(),
      'closeHour': closeHourCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('pharmacies').doc(uid).update(data);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour ✔️')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        backgroundColor: const Color.fromARGB(255, 37, 192, 58),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _newImage != null
                        ? FileImage(_newImage!)
                        : const AssetImage('assets/images/pharmas.png') as ImageProvider,
                    child: const Icon(Icons.edit, size: 30, color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _field(nameCtrl, 'Nom de la pharmacie'),
              const SizedBox(height: 12),
              _field(phoneCtrl, 'Téléphone / WhatsApp'),
              const SizedBox(height: 12),
              _field(locationCtrl, 'Localisation'),
              const SizedBox(height: 12),
              _field(openHourCtrl, 'Heure d\'ouverture (ex : 08:00)'),
              const SizedBox(height: 12),
              _field(closeHourCtrl, 'Heure de fermeture (ex : 20:00)'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) => TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v!.isEmpty ? 'Champ requis' : null,
      );
}


