// lib/pages/login_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../admin/dashboard_page.dart';
import 'dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // ⛔ MATIKAN AUTO LOGIN GOOGLE
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
  }

  // ======================
  // LOGIN EMAIL
  // ======================
  Future<void> login() async {
    setState(() => loading = true);

    final res = await http.post(
      Uri.parse("http://100.79.136.94:8080/login.php"),
      body: {
        "email": emailC.text.trim(),
        "password": passC.text.trim(),
      },
    );

    setState(() => loading = false);
    final data = json.decode(res.body);

    if (data['status'] == 'success') {
      final int userId = int.parse(data['user_id'].toString());
      final String role = data['role'];

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(userId: userId),
          ),
        );
      }
    } else {
      _msg("Login gagal");
    }
  }

  // ======================
  // LOGIN GOOGLE
  // ======================
  Future<void> loginGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user!;

      final res = await http.post(
        Uri.parse("http://100.79.136.94:8080/oauth_google.php"),
        body: {
          "email": user.email ?? "",
          "name": user.displayName ?? "",
        },
      );

      final data = json.decode(res.body);

      if (data['status'] == 'success') {
        final int userId = int.parse(data['user_id'].toString());
        final String role = data['role'];

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(userId: userId),
            ),
          );
        }
      } else {
        _msg("Login Google gagal");
      }
    } catch (e) {
      _msg("Login Google error");
    }
  }

  void _msg(String s) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(s)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Login", style: TextStyle(fontSize: 22)),
              const SizedBox(height: 16),

              TextField(
                controller: emailC,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passC,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: loading ? null : login,
                child: const Text("Login"),
              ),

              const SizedBox(height: 12),
              const Text("atau"),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.g_mobiledata),
                label: const Text("Login Google"),
                onPressed: loginGoogle,
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text("Belum punya akun? Daftar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
