import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class indexdetail extends StatefulWidget {
  const indexdetail({super.key});

  @override
  State<indexdetail> createState() => _indexdetailState();
}

class _indexdetailState extends State<indexdetail> {
  List<Map<String, dynamic>> detailpenjualan = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdetail();
  }

  Future<void> fetchdetail() async {
    try {
      final data = await Supabase.instance.client
          .from('detailpenjualan')
          .select('*, penjualan(*,pelanggan(*)), produk(*)');
      setState(() {
        detailpenjualan = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('error: $e')));
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: ListView.builder(
      itemCount: detailpenjualan.length,
      itemBuilder: (context, index) {
        final detail = detailpenjualan[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Latar belakang putih
              borderRadius: BorderRadius.circular(12.0), // Sudut melengkung
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.2), // Bayangan lembut
                  blurRadius: 8.0, // Menambah efek blur bayangan
                  offset: Offset(0, 4), // Posisi bayangan
                ),
              ],
            ),
            child: Card(
              elevation: 0, // Menghilangkan bayangan di Card agar tidak tumpang tindih
              margin: EdgeInsets.zero, // Menghilangkan margin default di Card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Sudut melengkung di Card
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail['penjualan']['pelanggan']['NamaPelanggan']?.toString() ??
                          'Pelanggan tidak tersedia',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87, // Warna teks yang lebih gelap
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      detail['produk']['NamaProduk'] ?? 'Produk tidak tersedia',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        color: Colors.grey[600], // Warna teks abu-abu
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      detail['JumlahProduk']?.toString() ?? 'Tidak tersedia',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blueGrey, // Warna teks biru kehijauan
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 8),
                    Text(
                      detail['Subtotal']?.toString() ?? 'Tidak tersedia',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green, // Warna hijau untuk subtotal
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

}