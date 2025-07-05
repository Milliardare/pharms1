import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _showAlreadyRegisteredDialog(String role) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('error_already_registered_title'.tr()),
        content: Text('error_already_registered_msg'.tr(args: [role])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok_button'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "password_mismatch".tr();
        _isLoading = false;
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final existingRole = querySnapshot.docs.first.get('role') ?? 'non défini';
        await _showAlreadyRegisteredDialog(existingRole);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'role': 'client',
        'email': email,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('signup_title'.tr()),
        backgroundColor: const Color.fromARGB(255, 252, 255, 252),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'email_label'.tr()),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'password_label'.tr(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'confirm_password_label'.tr(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                ),
                SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 10),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signup,
                        child: Text('signup_button'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 246, 250, 246),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('already_account'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'login_page.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SignupPage extends StatefulWidget {
//   @override
//   _SignupPageState createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   bool _isLoading = false;
//   String? _errorMessage;

//   Future<void> _showAlreadyRegisteredDialog(String role) async {
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Utilisateur déjà inscrit'),
//         content: Text('Cet utilisateur est déjà inscrit avec le rôle "$role".'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _signup() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final confirmPassword = _confirmPasswordController.text.trim();

//     if (password != confirmPassword) {
//       setState(() {
//         _errorMessage = "Les mots de passe ne correspondent pas.";
//         _isLoading = false;
//       });
//       return;
//     }

//     try {
//       // Avant de créer l'utilisateur, vérifie si email existe déjà dans 'users'
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         // L'email existe déjà, récupère le rôle
//         final existingRole = querySnapshot.docs.first.get('role') ?? 'non défini';
//         await _showAlreadyRegisteredDialog(existingRole);
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       // Création du compte Firebase Auth
//       UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Ajout dans Firestore uniquement si pas déjà existant
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set({
//         'role': 'client',
//         'email': email,
//       });

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => LoginPage()),
//       );
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         _errorMessage = e.message;
//       });
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Inscription"),
//         backgroundColor: const Color.fromARGB(255, 252, 255, 252),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(labelText: "Adresse e-mail"),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 TextField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: "Mot de passe",
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                   ),
//                   obscureText: _obscurePassword,
//                 ),
//                 TextField(
//                   controller: _confirmPasswordController,
//                   decoration: InputDecoration(
//                     labelText: "Confirmer le mot de passe",
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscureConfirmPassword = !_obscureConfirmPassword;
//                         });
//                       },
//                     ),
//                   ),
//                   obscureText: _obscureConfirmPassword,
//                 ),
//                 SizedBox(height: 20),
//                 if (_errorMessage != null)
//                   Text(_errorMessage!, style: TextStyle(color: Colors.red)),
//                 SizedBox(height: 10),
//                 _isLoading
//                     ? CircularProgressIndicator()
//                     : ElevatedButton(
//                         onPressed: _signup,
//                         child: Text("S'inscrire"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color.fromARGB(255, 246, 250, 246),
//                           minimumSize: Size(double.infinity, 50),
//                         ),
//                       ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Text("Déjà un compte ? Se connecter"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
