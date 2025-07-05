import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'WelcomePage.dart';
import 'signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => WelcomePage()),
          );
        } else {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('error_user_not_found_title'.tr()),
              content: Text('error_user_not_found_msg'.tr()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ok_button'.tr()),
                ),
              ],
            ),
          );
        }
      }
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
        title: Text('login_title'.tr()),
        backgroundColor: const Color.fromARGB(255, 248, 255, 248),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'email_label'.tr()),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
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
                      tooltip: _obscurePassword ? 'show_password'.tr() : 'hide_password'.tr(),
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 10),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: Text('login_button'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 243, 248, 244),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignupPage()),
                    );
                  },
                  child: Text('no_account'.tr()),
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
// import 'WelcomePage.dart'; // Assure-toi que WelcomePage accepte un paramètre "role"
// import 'signup_page.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _isLoading = false;
//   bool _obscurePassword = true; // Mot de passe caché par défaut
//   String? _errorMessage;

//   Future<void> _login() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );

//       User? user = userCredential.user;

//       if (user != null) {
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();

//         if (userDoc.exists) {
//           // Récupère le rôle et envoie à WelcomePage
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) => WelcomePage(),
//             ),
//           );
//         } else {
//           await showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               title: Text("Erreur"),
//               content: Text("Utilisateur non trouvé dans la base de données."),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text("OK"),
//                 ),
//               ],
//             ),
//           );
//         }
//       }
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
//         title: Text("Connexion"),
//         backgroundColor: const Color.fromARGB(255, 248, 255, 248),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(labelText: "Adresse e-mail"),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 SizedBox(height: 16),
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
//                 SizedBox(height: 20),
//                 if (_errorMessage != null)
//                   Text(_errorMessage!, style: TextStyle(color: Colors.red)),
//                 SizedBox(height: 10),
//                 _isLoading
//                     ? CircularProgressIndicator()
//                     : ElevatedButton(
//                         onPressed: _login,
//                         child: Text("Se connecter"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color.fromARGB(255, 243, 248, 244),
//                           minimumSize: Size(double.infinity, 50),
//                         ),
//                       ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => SignupPage()),
//                     );
//                   },
//                   child: Text("Pas encore de compte ? S'inscrire"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


