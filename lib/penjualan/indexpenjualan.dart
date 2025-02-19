import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_dinakasir/penjualan/insertpenjualan.dart';
import 'package:intl/intl.dart';

class indexpenjualan extends StatefulWidget {
  const indexpenjualan({super.key});

  @override
  State<indexpenjualan> createState() => _indexpenjualanState();
}

class _indexpenjualanState extends State<indexpenjualan> {
  List<Map<String, dynamic>> penjualan = [];
  List<Map<String, dynamic>> penjualanFiltered = []; // Variabel untuk menyimpan hasil pencarian

  bool isLoading = true;

  String searchQuery = "";

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
          item['date'] = DateFormat('dd-MM-yyyy').format(DateTime.timestamp());
          // item['date'] = DateTime.now().toString();
          return item;
        }).toList();
        penjualanFiltered = penjualan;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching penjualan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk mencari penjualan berdasarkan kata kunci pencarian
  void searchPenjualan(String query) {
    setState(() {
      searchQuery = query;
      penjualanFiltered = penjualan.where((jual) {
        return jual['pelanggan']['NamaPelanggan'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }
  
  String formatCurrency(dynamic value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);
    return formatter.format(value ?? 0);
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
                  searchPenjualan(query);
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
          // ListView to display filtered penjualan
          Expanded(
            child: ListView.builder(
              itemCount: penjualanFiltered.length,
              itemBuilder: (context, index) {
                final item = penjualanFiltered[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.2),
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        item['pelanggan']['NamaPelanggan'],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Total harga: ${formatCurrency(item['TotalHarga'])}\nTanggal: ${item['date']}',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var sales = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => insertpenjualan()),
          );

          if (sales == true) {
            fetchPenjualan(); // Fetch updated data
          }
        },
        child: Icon(
          Icons.add,
          color: Colors.brown[300],
        ),
        backgroundColor: Colors.brown[600],
      ),
    );
  }


}