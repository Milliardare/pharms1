import 'package:flutter/material.dart';
import 'package:pharmacietest1/PharmacySignupPage.dart';
import 'AdminAddLivreurPage.dart';
import 'AjouterProduitPage.dart';
import 'AdminDeleteLivreurPage.dart';
import 'AdminDeletePharmacyPage.dart';
import 'SupprimerProduitPage.dart';
import 'ModifierNumeroWhatsAppPage.dart';
import 'PharmacyDataUploaderPage.dart';
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  // Couleurs principales
  final Color greenColor = const Color(0xFF25C03A);
  final Color orangeColor = const Color(0xFFEF6C00);
  final Color greyLight = const Color(0xFFF5F5F5);

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 26),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 4,
        shadowColor: backgroundColor.withOpacity(0.5),
      ),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Administrateur'),
        backgroundColor: greenColor,
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      backgroundColor: Colors.white,

      body: SingleChildScrollView(  // ← Ajouté ici
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings, size: 90, color: greenColor),
              const SizedBox(height: 16),
              const Text(
                'Bienvenue dans le panneau d’administration',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),
              _buildButton(
                icon: Icons.person_add,
                label: 'Créer un livreur',
                backgroundColor: greenColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminAddLivreurPage()),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildButton(
                icon: Icons.person_remove,
                label: 'Supprimer un livreur',
                backgroundColor: greenColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminDeleteLivreurPage()),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildButton(
                icon: Icons.local_pharmacy,
                label: 'Créer une pharmacie',
                backgroundColor: orangeColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PharmacySignupPage()),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildButton(
                icon: Icons.local_pharmacy_outlined,
                label: 'Supprimer une pharmacie',
                backgroundColor: orangeColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminDeletePharmacyPage()),
                  );
                },
              ),
               const SizedBox(height: 24),
              _buildButton(
                icon: Icons.local_pharmacy_outlined,
                label: 'ajouter plusieurs pharmacies',
                backgroundColor: greenColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PharmacyDataUploaderPage()),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildButton(
                icon: Icons.medical_services_outlined,
                label: 'Ajouter un médicament pharmacie',
                backgroundColor: greyLight,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AjouterProduitPage()),
                  );
                },
              ),
                  const SizedBox(height: 24),
              _buildButton(
                icon: Icons.medical_services_outlined,
                label: 'Suprimer un médicament pharmacie',
                backgroundColor: greyLight,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SupprimerProduitPage()),
                  );
                },
              ),
                  const SizedBox(height: 24),
              _buildButton(
                icon: Icons.phone,
                label: 'Modifier le numero whatsapp de la boutique',
                backgroundColor: greyLight,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ModifierNumeroWhatsAppPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


