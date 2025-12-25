import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({super.key});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final userC = TextEditingController();
  final passC = TextEditingController();

  Future<void> _load() async {
    final pref = await SharedPreferences.getInstance();
    userC.text = pref.getString('user') ?? '';
    passC.text = pref.getString('pass') ?? '';
  }

  Future<void> _save() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('user', userC.text);
    await pref.setString('pass', passC.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui')));
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(title: const Text('Update User & Password')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: userC, decoration: const InputDecoration(labelText: 'User')),
                const SizedBox(height: 12),
                TextField(controller: passC, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
