import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_dinakasir/home.dart';

class insertproduk extends StatefulWidget {
  const insertproduk({super.key});

  @override
  State<insertproduk> createState() => _insertprodukState();
}

class _insertprodukState extends State<insertproduk> {
  final _nmprd = TextEditingController();
  final _harga = TextEditingController();
  final _stok = TextEditingController();
  final _formKey = GlobalKey<FormState>();

   Future<void> produk() async{
    if (_formKey.currentState!.validate()) {
      final NamaProduk = _nmprd.text;
      final Harga = _harga.text ;
      final Stok = _stok.text ;

      final response = await Supabase.instance.client.from('produk').insert([
        {
          'NamaProduk' : NamaProduk,
          'Harga': Harga,
          'Stok': Stok,
        }
      ]);
      
      if (response!= null) {
        Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) => homepage()),
        );
      } else {
        Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => homepage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Produk'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nmprd,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _harga,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  border:OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty){
                  return 'tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _stok,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: produk, 
              child: Text('Tambah'))
            ],
          ),
        ),
      ),
    );
  }
}