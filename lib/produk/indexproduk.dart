import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ukk_dinakasir/produk/insertproduk.dart';
import 'package:ukk_dinakasir/produk/updateproduk.dart';


class indexproduk extends StatefulWidget {
  const indexproduk({super.key});

  @override
  State<indexproduk> createState() => _indexprodukState();
}

class _indexprodukState extends State<indexproduk> {
  List<Map<String, dynamic>> produk = [];
  // List<Map<String, dynamic>> cart = [];
  //keranjang
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Supabase.instance.client.from('produk').select();
      setState(() {
        produk = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('error fetching produk: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteProduk(int id) async {
    try {
      await Supabase.instance.client
      .from('produk')
      .delete().
      eq('ProdukID', id);
      fetchProduk();
    } catch (e) {
      print('error deleting produk: $e');
    }
  }

  // Future<void> tambahKePenjualan(
  //     int ProdukID, String NamaProduk, int Harga, int jumlah) async {
  //   try {
  //     final response = await Supabase.instance.client.from('penjualan').insert({
  //       'ProdukID': ProdukID,
  //       'NamaProduk': NamaProduk,
  //       'Harga': Harga,
  //       'Jumlah': jumlah,
  //       'Total': Harga * jumlah, // Hitung total harga
  //       'Tanggal': DateTime.now().toIso8601String(), // Tambahkan tanggal
  //     });

  //     if (response != null) {
  //       print('Produk berhasil ditambah ke penjualan.');
  //     }
  //   } catch (e) {
  //     print('Gagal menambah ke penjualan: $e');
  //   }
  // }

  // void _addToCart(Map<String, dynamic> prd) {
  //   setState(() {
  //     cart.add(prd);
  //   });
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //         content:
  //             Text('Produk ${prd['NamaProduk']} ditambahkan ke keranjang')),
  //   );
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => homepage(
  //                 cart: cart,
  //               )));
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
      ? Center(
        child: LoadingAnimationWidget.twoRotatingArc(color: Colors.grey, size: 30),
      )
      : produk.isEmpty
      ? Center(
        child: Text(
          'tidak ada produk',
          style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold
          ),
        ),
      )
      : ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: produk.length,
        itemBuilder: (context, index) {
          final prd = produk[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prd['NamaProduk'] ?? 'Nama Tidak Tersedia',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )
                    ),
                    Text(
                      prd['Harga'] != null
                      ? prd['Harga'].toString()
                      : 'Harga Tidak Tersedia',
                      style: TextStyle(
                        color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                      ),
                    ),
                    Text(
                      prd['Stok'] != null
                      ? prd['Stok'].toString()
                      : 'Stok Tidak Tersedia',
                      style: TextStyle(
                        color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            final ProdukID = prd['ProdukID'] ?? 0; // Pastikan ini sesuai dengan kolom di database
                            if (ProdukID != 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => updateproduk(ProdukID: ProdukID))
                              );
                            } else {
                              print('ID produk tidak valid');
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Hapus Produk'),
                                    content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                          Navigator.pop(context), child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          deleteProduk(prd['ProdukID']);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => insertproduk()));
          },
          child: Icon(
            Icons.add, color: Colors.brown[300],
          )
        )
    );
  }
}