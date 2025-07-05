import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class OrderFormPage extends StatefulWidget {
  @override
  _OrderFormPageState createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController pharmacieController = TextEditingController();
  final TextEditingController lieuLivraisonController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    telController.text = '+';
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    telController.dispose();
    pharmacieController.dispose();
    lieuLivraisonController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('commandes').add({
        'nom': nomController.text.trim(),
        'prenom': prenomController.text.trim(),
        'telephone': telController.text.trim(),
        'pharmacie': pharmacieController.text.trim(),
        'lieuLivraison': lieuLivraisonController.text.trim(),
        'dateCommande': Timestamp.now(),
        'statut': 'en_attente',
        'livreurId': null,
      });

      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('order_saved'.tr()),
          content: Text('order_sent_success'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _formKey.currentState!.reset();
                nomController.clear();
                prenomController.clear();
                telController.text = '+';
                pharmacieController.clear();
                lieuLivraisonController.clear();
              },
              child: Text('ok'.tr()),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('order_send_error'.tr()),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String errorMsg,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? customValidator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: const Color.fromARGB(255, 37, 192, 58)) : null,
        labelText: label.tr(),
        hintText: hint.tr(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green.shade700, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: customValidator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return errorMsg.tr();
            }
            return null;
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('order_form_title'.tr()),
        backgroundColor: const Color.fromARGB(255, 37, 192, 58),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'attention'.tr(),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'order_warning'.tr(),
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              SizedBox(height: 30),

              _buildTextField(
                controller: nomController,
                label: 'label_name',
                hint: 'hint_name',
                errorMsg: 'error_name',
                icon: Icons.person,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s\-]')),
                ],
              ),
              SizedBox(height: 20),

              _buildTextField(
                controller: prenomController,
                label: 'label_firstname',
                hint: 'hint_firstname',
                errorMsg: 'error_firstname',
                icon: Icons.person_outline,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s\-]')),
                ],
              ),
              SizedBox(height: 20),

              _buildTextField(
                 controller: telController,
                 label: 'label_phone',
                   hint: '+241 06543210/ +33', // exemple clair avec indicatif Gabon
                   errorMsg: 'error_phone',
                   icon: Icons.phone,
                    inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9\s]{0,15}$')), // chiffres et espaces
                   LengthLimitingTextInputFormatter(15),
                     ],
                     keyboardType: TextInputType.phone,
                        customValidator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'error_phone'.tr();
                            }
                        if (!value.startsWith('+241')) {
                          return 'Veuillez commencer par l’indicatif +241'.tr();
                            }
                               final digitsOnly = value.replaceAll(' ', '').substring(1); // sans '+'
                                 if (digitsOnly.length < 8 || digitsOnly.length > 12) {
                           return 'invalid_number'.tr();
                                }
                            return null;
              },
                  ),
SizedBox(height: 6),
Text(
  'ex: +241 06543210',
  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          
              ),
              SizedBox(height: 20),

              _buildTextField(
                controller: pharmacieController,
                label: 'label_pharmacy',
                hint: 'hint_pharmacy',
                errorMsg: 'error_pharmacy',
                icon: Icons.local_pharmacy,
              ),
              SizedBox(height: 20),

              _buildTextField(
                controller: lieuLivraisonController,
                label: 'label_delivery_place',
                hint: 'hint_delivery_place',
                errorMsg: 'error_delivery_place',
                icon: Icons.location_on,
              ),

              SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(Icons.check_circle),
                  label: Text(
                    _isLoading ? 'sending_order'.tr() : 'confirm_order'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 37, 192, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _submitOrder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


