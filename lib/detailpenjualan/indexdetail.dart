import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_dinakasir/detailpenjualan/cetakpdf.dart';

class indexdetail extends StatefulWidget {
  const indexdetail({super.key});

  @override
  State<indexdetail> createState() => _indexdetailState();
}

class _indexdetailState extends State<indexdetail> {
  List<Map<String, dynamic>> detailpenjualan = [];
  List<Map<String, dynamic>> detailFiltered = [];

  String searchQuery = "";

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

  // Fungsi untuk mencari detail berdasarkan kata kunci pencarian
  void searchDetail(String query) {
    setState(() {
      searchQuery = query;
      detailFiltered = detailpenjualan.where((jual) {
        return jual['pelanggan']['NamaPelanggan'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  //kode alert dialog ke halman cetakpdf
  void showPrintDialog(Map<String, dynamic> detail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Riwayat Transaksi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Nama Pelanggan: ${detail['penjualan']['pelanggan']['NamaPelanggan'] ?? 'Tidak tersedia'}'),
                SizedBox(height: 8),
                Text('Nama Produk: ${detail['produk']['NamaProduk'] ?? 'Tidak tersedia'}'),
                SizedBox(height: 8),
                Text('Jumlah Produk: ${detail['JumlahProduk']?.toString() ?? 'Tidak tersedia'}'),
                SizedBox(height: 8),
                Text('Subtotal: ${detail['Subtotal']?.toString() ?? 'Tidak tersedia'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cetak Struk'),
              onPressed: () {
                // Route ke halaman cetak pdf
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => cetakpdf(
                    cetak: detail, 
                    PenjualanID: detail['penjualan']['PenjualanID'].toString(),
                  ),
                ),
              );

              },
            ),
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
            child: Expanded(
              child: TextField(
                onChanged: (query) {
                  searchDetail(query);
                },
                decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5)),
                        ),
                      ),
              ),
            ),
        ),
        Expanded(
    child: ListView.builder(
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
                    SizedBox(height:8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                    ElevatedButton(
                      onPressed: () => showPrintDialog(detail),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.print,
                            color: Colors.brown[400]
                          ),
                        ],
                      ),
                    )
                    ]
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
    )
    ]
    )
  );
}
}