import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // pour kIsWeb
import 'dart:io';

class AjouterProduitPage extends StatefulWidget {
  @override
  _AjouterProduitPageState createState() => _AjouterProduitPageState();
}

class _AjouterProduitPageState extends State<AjouterProduitPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  XFile? _pickedFile;
  bool _isLoading = false;

  // 🔥 Ajout du champ Catégorie
  String? _selectedCategorie;
  final List<String> _categories = [
    'Crème', 'Lotion', 'Sirop', 'Complément', 'Hygiène'
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  Future<String?> _uploadImageToCloudinary() async {
    if (_pickedFile == null) return null;

    const String uploadPreset = 'pharmas_preset';
    const String cloudName = 'dkrt5dnd9';
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset;

      if (kIsWeb) {
        final bytes = await _pickedFile!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: _pickedFile!.name),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', _pickedFile!.path),
        );
      }

      final streamedResponse = await request.send();
      final resBody = await streamedResponse.stream.bytesToString();
      final data = json.decode(resBody);

      if (streamedResponse.statusCode == 200 && data['secure_url'] != null) {
        return data['secure_url'];
      } else {
        print('Erreur Cloudinary : $resBody');
        return null;
      }
    } catch (e) {
      print("Exception lors de l'upload : $e");
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ajoutez une image du produit.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final imageUrl = await _uploadImageToCloudinary();

    if (imageUrl == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur d'envoi de l'image.")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('boutique').add({
      'nom': _nomController.text.trim(),
      'description': _descriptionController.text.trim(),
      'categorie': _selectedCategorie, // ✅ ajout catégorie ici
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _isLoading = false;
      _nomController.clear();
      _descriptionController.clear();
      _pickedFile = null;
      _selectedCategorie = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Produit ajouté à la boutique.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un produit"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: "Nom du médicament"),
                validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              
              // ✅ Choix de la catégorie
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Catégorie"),
                value: _selectedCategorie,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategorie = value;
                  });
                },
                validator: (value) => value == null ? 'Sélectionnez une catégorie' : null,
              ),
              SizedBox(height: 16),

              GestureDetector(
                onTap: _pickImage,
                child: _pickedFile == null
                    ? Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                      )
                    : kIsWeb
                        ? Image.network(_pickedFile!.path, height: 150, fit: BoxFit.cover)
                        : Image.file(File(_pickedFile!.path), height: 150, fit: BoxFit.cover),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProduct,
                icon: Icon(Icons.save),
                label: Text("Ajouter à la boutique"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



