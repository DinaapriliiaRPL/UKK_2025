import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_dinakasir/registrasi/indexuser.dart';

class insertuser extends StatefulWidget {
  const insertuser({super.key});

  @override
  State<insertuser> createState() => _InsertUserState();
}

class _InsertUserState extends State<insertuser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _role = TextEditingController();

  // Fungsi untuk membuat salt acak
  String generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // Fungsi untuk hash password dengan salt
  String hashPasswordWithSalt(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Method untuk insert user dengan password terenkripsi
  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _username.text;
    final password = _password.text;
    final role = _role.text;

    if (username.isEmpty || password.isEmpty || role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua bidang wajib diisi')),
      );
      return;
    }

    // Generate salt unik dan hash password
    final salt = generateSalt();
    final hashedPassword = hashPasswordWithSalt(password, salt);

    final response = await Supabase.instance.client.from('user').insert([
      {
        'username': username,
        'password': hashedPassword, // Simpan password yang sudah di-hash
        'salt': salt, // Simpan salt agar bisa digunakan saat login
        'role': role,
      }
    ]);

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error!.message}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User berhasil ditambahkan')),
      );
    }

    // Kosongkan form setelah berhasil menambahkan user
    _username.clear();
    _password.clear();
    _role.clear();

    // Kembali ke halaman daftar user
    Navigator.pop(context, true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => userpage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[600],
        title: const Text(
          'Tambah User',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: true, // Sembunyikan password saat diketik
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Role tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addUser();
                  }
                },
                child: Text('Tambah User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
