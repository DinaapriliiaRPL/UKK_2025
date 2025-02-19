import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_dinakasir/registrasi/indexuser.dart';

class updateuser extends StatefulWidget {
  final int id;

  const updateuser({super.key, required this.id});

  @override
  State<updateuser> createState() => _updateuserState();
}

class _updateuserState extends State<updateuser> {
  final _user = TextEditingController();
  final _password = TextEditingController();
  final _role = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _oldPasswordHash;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  /// Fungsi untuk mengenkripsi password dengan SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Mengambil data user dari Supabase
  Future<void> fetchUserDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('user')
          .select()
          .eq('id', widget.id)
          .single();
      
      setState(() {
        _user.text = response['username'] ?? '';
        _role.text = response['role'] ?? '';
        _oldPasswordHash = response['password']; // Simpan password lama yang sudah di-hash
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Memperbarui data user di Supabase dengan hashing password
  Future<void> updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updates = {
          'username': _user.text,
          'role': _role.text,
        };

        // Jika password diisi, hash dan update password baru
        if (_password.text.isNotEmpty) {
          updates['password'] = hashPassword(_password.text);
        } else {
          // updates['password'] = _oldPasswordHash; // Jika kosong, gunakan password lama
        }

        await Supabase.instance.client
            .from('user')
            .update(updates)
            .eq('id', widget.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User berhasil diperbarui!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => userpage()),
        );
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[600],
        title: const Text('Update User', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _user,
                decoration: const InputDecoration(
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
                decoration: const InputDecoration(
                  labelText: 'Password (Kosongkan jika tidak ingin mengubah)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Password hidden
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
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: updateUserData,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
