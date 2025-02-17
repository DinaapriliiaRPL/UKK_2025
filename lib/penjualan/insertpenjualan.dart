import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class insertpenjualan extends StatefulWidget {
  const insertpenjualan({super.key});

  @override
  State<insertpenjualan> createState() => _insertpenjualanState();
}

class _insertpenjualanState extends State<insertpenjualan> {
  final SingleValueDropDownController nameController =
      SingleValueDropDownController();
  final SingleValueDropDownController produkController =
      SingleValueDropDownController();
  final TextEditingController quantityController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  
  List myproduct = [];
  List user = [];

  takeProduct() async {
    var product = await Supabase.instance.client.from('produk').select();
    setState(() {
      myproduct = product;
    });
  }

  takePelanggan() async {
    var pelanggan = await Supabase.instance.client.from('pelanggan').select();
    setState(() {
      user = pelanggan;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    takeProduct();
    takePelanggan();
  }

  void addPelanggan() {

    final String name = nameController.dropDownValue!.value;
    final int quantity = int.parse(quantityController.text);
    print('Pelanggan Name: $name, Quantity: $quantity');
    // Kembali ke layar sebelumnya setelah menambahkan produk
    Navigator.of(context).pop();
  }

  void addProduct() {
    // Implementasikan logika untuk menambahkan produk, misalnya, kirim data ke Supabase
    final String name = nameController.dropDownValue!.value;
    final int quantity = int.parse(quantityController.text);
    print('Product Name: $name, Quantity: $quantity');
    // Kembali ke layar sebelumnya setelah menambahkan produk
    Navigator.of(context).pop();
  }

  void executeSales() async {
    if(!_formKey.currentState!.validate()) return;

    var penjualan = await Supabase.instance.client
        .from('penjualan')
        .insert([
          {
            "PelangganID": nameController.dropDownValue!.value["PelangganID"],
            "TotalHarga": ((produkController.dropDownValue!.value["Harga"] *
                int.parse(quantityController.text)) as int)
          }
        ])
        .select()
        .single();
    if (penjualan.isNotEmpty) {
      var detailPenjualan =
          await Supabase.instance.client.from('detailpenjualan').insert([
        {
          "PenjualanID": penjualan["PenjualanID"],
          "ProdukID": produkController.dropDownValue!.value["ProdukID"],
          'JumlahProduk': int.parse(quantityController.text),
          'Subtotal': ((produkController.dropDownValue!.value["Harga"] *
              int.parse(quantityController.text)) as int)
        }
      ]);
      if (detailPenjualan == null) {
        var product = await Supabase.instance.client.from('produk').update({
          'Stok': produkController.dropDownValue!.value["Stok"] -
              int.parse(quantityController.text)
        }).eq('ProdukID', produkController.dropDownValue!.value["ProdukID"]);
        if (product == null) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[600],
        title: const Text('Tambah Data', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white), // Ganti ikon panah menjadi '<'
          onPressed: () {
            Navigator.pop(
                context, true); // Fungsi untuk kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropDownTextField(
                dropDownList: [
                  ...List.generate(user.length, (index) {
                    return DropDownValueModel(
                        name: user[index]['NamaPelanggan'], value: user[index]);
                  })
                  
                ],
                controller: nameController,
                textFieldDecoration: InputDecoration(
                  labelText: "Select User",
                  border: OutlineInputBorder()
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Pelanggan tidak boleh kosong' ;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropDownTextField(
                dropDownList: [
                  ...List.generate(myproduct.length, (index) {
                    return DropDownValueModel(
                        name: myproduct[index]['NamaProduk'],
                        value: myproduct[index]);
                  })
                ],
                controller: produkController,
                textFieldDecoration:
                    InputDecoration(
                      labelText: "Select Produk",
                      border: OutlineInputBorder()
                    ),
                validator: (value) {
                  if (value == null) {
                    return 'Produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder()
                ),
                keyboardType: TextInputType.number,
                

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Jumlah harus lebih besar dari 0';
                  }
                  return null;
                },
              

              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  executeSales();
                },
                child: Text('Checkout'),
              ),
            ],
          ),
         ),
      ),
    );
  }
}
