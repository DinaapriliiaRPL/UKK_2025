import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_dinakasir/home.dart';
import 'package:intl/intl.dart';
import 'package:ukk_dinakasir/penjualan/indexpenjualan.dart';

class insertpenjualan extends StatefulWidget {
  const insertpenjualan({super.key});

  @override
  State<insertpenjualan> createState() => _insertpenjualanState();
}

class _insertpenjualanState extends State<insertpenjualan> {
  final _formKey = GlobalKey<FormState>();

  DateTime currentDate = DateTime.now();

  List<Map<String, dynamic>> pelanggan = [];
  List<Map<String, dynamic>> produk = [];
  Map<String, dynamic>? pilihPelanggan;
  Map<String, dynamic>? pilihProduk;

  TextEditingController quantityController = TextEditingController();
  double subtotal = 0;
  double totalHarga = 0;
  List<Map<String, dynamic>> keranjang = [];

  //formater angka dg pemisah ribuan dan dua angka desimal
  final currencyFormatter = NumberFormat("#,##0.00", "id_ID");


  @override
  void initState() {
    super.initState();
    fetchPelanggan();
    fetchProduk();
  }

  Future<void> fetchPelanggan() async {
    final response = await Supabase.instance.client.from('pelanggan').select();
    setState(() {
      pelanggan = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> fetchProduk() async {
    final response = await Supabase.instance.client.from('produk').select();
    setState(() {
      produk = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> tambahKeKeranjang() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (pilihProduk != null && quantityController.text.isNotEmpty) {
        int quantity = int.parse(quantityController.text);
        double price = pilihProduk!['Harga'];
        double itemSubtotal = price * quantity;

        if (pilihProduk!['Stok'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stok sudah habis'),
              backgroundColor: Colors.brown[200],
            ),
          );
          return;
        }

        if (pilihProduk!['Stok'] < quantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stok tidak cukup'),
              backgroundColor: Colors.brown[200],
            ),
          );
          return;
        }

      //fungsi agar produk tidak satu satu
        setState(() {
          // Cek apakah produk sudah ada di keranjang
          int existingIndex = keranjang.indexWhere(
            (item) => item['ProdukID'] == pilihProduk!['ProdukID'],
          );

          if (existingIndex != -1) {
            // Jika produk sudah ada, update jumlah dan subtotal
            keranjang[existingIndex]['JumlahProduk'] += quantity;
            keranjang[existingIndex]['Subtotal'] += itemSubtotal;
          } else {
            // Jika produk belum ada, tambahkan ke keranjang
            keranjang.add({
              'ProdukID': pilihProduk!['ProdukID'],
              'NamaProduk': pilihProduk!['NamaProduk'],
              'JumlahProduk': quantity,
              'Subtotal': itemSubtotal,
            });
          }

          // Update total harga
          totalHarga = keranjang.fold(0, (sum, item) => sum + item['Subtotal']);

          // Kurangi stok produk yang dipilih
          pilihProduk!['Stok'] -= quantity;
        });
      }
    }
  }

  Future<void> SubmitPenjualan() async {
    try {
      final penjualanResponse = await Supabase.instance.client
          .from('penjualan')
          .insert({
            'TanggalPenjualan': DateFormat('yyy-MM-dd').format(currentDate),
            'TotalHarga': totalHarga,
            'PelangganID': pilihPelanggan!['PelangganID']
          })
          .select()
          .single();

      final PenjualanID = penjualanResponse['PenjualanID'];

      for (var item in keranjang) {
        await Supabase.instance.client.from('detailpenjualan').insert({
          'PenjualanID': PenjualanID,
          'ProdukID': item['ProdukID'],
          'JumlahProduk': item['JumlahProduk'],
          'Subtotal': item['Subtotal']
        });

        await Supabase.instance.client.from('produk').update(
            {'Stok': pilihProduk!['Stok']}).eq('ProdukID', item['ProdukID']);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaksi berhasil disimpan'),
          backgroundColor: Colors.brown[200],
        ),
      );
      setState(() {
        keranjang.clear();
        totalHarga = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.brown[200],
        ),
      );
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => indexpenjualan()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Transaksi Penjualan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown[600],
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Select User',
                  border: OutlineInputBorder()
                ),
                items: pelanggan.map((customer) {
                  return DropdownMenuItem(
                    value: customer,
                    child: Text(customer['NamaPelanggan']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    pilihPelanggan = value as Map<String, dynamic>;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Pelanggan wajib diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Select Product',
                  border: OutlineInputBorder()
                ),
                items: produk.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(product['NamaProduk']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    pilihProduk = value as Map<String, dynamic>;
                    subtotal = pilihProduk!['Harga'] *
                        (quantityController.text.isEmpty
                            ? 0
                            : int.parse(quantityController.text));
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Produk wajib diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Produk',
                  border: OutlineInputBorder()
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    subtotal = pilihProduk != null
                        ? pilihProduk!['Harga'] * int.parse(value)
                        : 0;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah Produk wajib diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: tambahKeKeranjang,
                child: Text('Tambahkan ke Keranjang',
                    style: TextStyle(color: Colors.brown[600])),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: keranjang.length,
                  itemBuilder: (context, index) {
                    final item = keranjang[index];
                    return ListTile(
                      title: Text(item['NamaProduk']),
                      subtitle: Text(
                          'Jumlah: ${item['JumlahProduk']} - Subtotal: Rp ${currencyFormatter.format(item['Subtotal'])}'),
                    );
                  },
                ),
              ),
              Divider(),
              Text('Total Harga: Rp ${currencyFormatter.format(totalHarga)}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: SubmitPenjualan,
                child: Text(
                  'Checkout',
                  style: TextStyle(color: Colors.brown[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}