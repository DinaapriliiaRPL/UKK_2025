import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_dinakasir/penjualan/insertpenjualan.dart';

class indexpenjualan extends StatefulWidget {
  const indexpenjualan({super.key});

  @override
  State<indexpenjualan> createState() => _indexpenjualanState();
}

class _indexpenjualanState extends State<indexpenjualan> {
  List<Map<String, dynamic>> penjualan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPenjualan();
  }

  Future<void> fetchPenjualan() async {
    // setState(() {
    //   isLoading = true;
    // });
    try {
      final response = await Supabase.instance.client
          .from('penjualan')
          .select('*, pelanggan(*)');
      setState(() {
        penjualan = List<Map<String, dynamic>>.from(response).map((item) {
          item['date'] = DateTime.now().toString();
          return item;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching penjualan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ListView.builder(
      itemCount: penjualan.length,
      itemBuilder: (context, index) {
        final item = penjualan[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Warna latar belakang
              borderRadius: BorderRadius.circular(12.0), // Membuat sudut melengkung
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.2), // Warna bayangan
                  blurRadius: 8.0, // Seberapa kabur bayangannya
                  offset: Offset(0, 4), // Posisi bayangan
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0), // Memberikan padding di dalam ListTile
              title: Text(
                item['pelanggan']['NamaPelanggan'],
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                'Total harga: ${item['TotalHarga']}\nTanggal: ${item['date']}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600], // Warna subtitle
                ),
              ),
            ),
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        var sales = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => insertpenjualan()),
        );

        if (sales == true) {
          fetchPenjualan();
        }
      },
      child: Icon(
        Icons.add,
        color: Colors.brown[300],
      ),
      backgroundColor: Colors.brown[600], // Warna tombol aksi
    ),
  );
}

}