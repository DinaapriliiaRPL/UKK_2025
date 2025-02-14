import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_dinakasir/registrasi/indexuser.dart';

class insertuser extends StatefulWidget {
  const insertuser({super.key});

  @override
  State<insertuser> createState() => _insertuserState();
}

class _insertuserState extends State<insertuser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _role = TextEditingController();

  //method utk insert data user ke supabases
  Future<void> _adduser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _username.text;
    final password = _password.text;
    final role = _role.text;

    //validasi input
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua wajib diisi')),
      );
      return;
    }

    final response = await Supabase.instance.client.from('user').insert([
      {
        'username': username,
        'password': password,
        'role': 'petugas',
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

    //jika form sudah selesai input maka kosongkan form dg cara perintah ini
    _username.clear();
    _password.clear();

    //navigasi jika kembali ke halaman sebelumnya dan refresh list
    Navigator.pop(context, true);
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => userpage())
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
          icon: const Icon(Icons.chevron_left, color: Colors.white,),
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
                  border: OutlineInputBorder()
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
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder()
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox( height: 16),
              TextFormField(
                controller: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder()
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Role tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _adduser();
                  }
                },
                child: Text('Tambah User'),
              )
            ],
          )
        ),
      )
    );
  }
}