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

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

   Future<void> fetchUserDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('user')
          .select()
          .eq('id', widget.id)
          .single();
      setState(() {
        _user.text = response['username'] ?? '';
        _password.text = response['password']?.toString() ?? '';
        _role.text = response['role'] ?? '';
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  // Update user data di db
  Future<void> updateuserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Supabase.instance.client.from('user').update({
          'username': _user.text,
          'password': _password.text,
          'role': _role.text
        }).eq('id', widget.id);

        //jika berhasil akan tampil di halaman userpage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => userpage()),
        );
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[600],
        title: const Text(
          'Update User', 
          style: TextStyle(color: Colors.white)
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
        padding: EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _user,
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
              SizedBox(height: 16),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Password hidden
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _role,
                decoration: InputDecoration(
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
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: updateuserData,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}