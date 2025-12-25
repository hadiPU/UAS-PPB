import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminKonsumenPage extends StatefulWidget {
  const AdminKonsumenPage({super.key});

  @override
  State<AdminKonsumenPage> createState() => _AdminKonsumenPageState();
}

class _AdminKonsumenPageState extends State<AdminKonsumenPage> {
  List data = [];

  Future<void> load() async {
    final res = await http.get(
      Uri.parse("http://192.168.10.115/blangkis/api/admin/konsumen_crud.php"),
    );
    data = json.decode(res.body);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Konsumen")),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(data[i]['nama']),
          subtitle: Text(data[i]['no_hp']),
        ),
      ),
    );
  }
}
