import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class PharmacySignupPage extends StatefulWidget {
  @override
  _PharmacySignupPageState createState() => _PharmacySignupPageState();
}

class _PharmacySignupPageState extends State<PharmacySignupPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final openHourCtrl = TextEditingController();
  final closeHourCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  File? _selectedImage;
  bool _isUploading = false;
  bool _obscurePassword = true; // 👈 contrôle visibilité

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> savePharmacy() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      // 1. Créer compte Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // 2. Enregistrer infos dans Firestore (ID = uid)
      final data = {
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'openHour': openHourCtrl.text.trim(),
        'closeHour': closeHourCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'role': 'pharmacy',
        'imageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('pharmacies').doc(uid).set(data);

      // Enregistrer aussi dans 'users' avec les clés en anglais
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': emailCtrl.text.trim(),
        'role': 'pharmacy',
        'name': nameCtrl.text.trim(),   // clé corrigée ici
        'phone': phoneCtrl.text.trim(), // clé corrigée ici
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pharmacy successfully registered')),
      );

      _formKey.currentState?.reset();
      nameCtrl.clear();
      phoneCtrl.clear();
      locationCtrl.clear();
      emailCtrl.clear();
      passCtrl.clear();
      setState(() {
        _selectedImage = null;
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pharmacy Registration')),
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
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : AssetImage('assets/images/pharmas.png') as ImageProvider,
                    child: _selectedImage == null
                        ? Icon(Icons.camera_alt, size: 30, color: Colors.white70)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Pharmacy Name', border: OutlineInputBorder()),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                validator: (v) => v!.isEmpty ? 'Enter pharmacy name' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                decoration: InputDecoration(labelText: 'Phone / WhatsApp', border: OutlineInputBorder()),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v!.isEmpty ? 'Enter a phone number' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: openHourCtrl,
                decoration: InputDecoration(labelText: 'Opening Hour (ex: 08:00)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter opening hour' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: closeHourCtrl,
                decoration: InputDecoration(labelText: 'Closing Hour (ex: 20:00)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter closing hour' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: locationCtrl,
                decoration: InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                validator: (v) => v!.isEmpty ? 'Enter location' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'Login Email', border: OutlineInputBorder()),
                validator: (v) => v!.contains('@') ? null : 'Invalid email',
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: passCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (v) => v!.length < 6 ? 'Password too short' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : savePharmacy,
                child: _isUploading ? CircularProgressIndicator() : Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

