import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ukk_dinakasir/pelanggan/insertpelanggan.dart';
import 'package:ukk_dinakasir/pelanggan/updatepelanggan.dart';

class indexpelanggan extends StatefulWidget {
  const indexpelanggan({super.key});

  @override
  State<indexpelanggan> createState() => _indexpelangganState();
}

class _indexpelangganState extends State<indexpelanggan> {
  List<Map<String, dynamic>> pelanggan = [];
  List<Map<String, dynamic>> pelangganFiltered = [];

  bool isLoading = true;

  String searchQuery = ""; //variabel untuk menyimpan kata kunci pencarian

  @override 
  void initState() {
    super.initState();
    fetchPelanggan();
  }

    //fungsi untuk mengambil data pelanggan dari supabase
  Future<void> fetchPelanggan() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await Supabase.instance.client.from('pelanggan').select();
      setState(() {
        pelanggan = List<Map<String, dynamic>>.from(response);
        pelangganFiltered = pelanggan;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pelanggan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deletePelanggan(int id) async {
    try {
      await Supabase.instance.client
        .from('pelanggan')
        .delete()
        .eq('PelangganID', id);
      fetchPelanggan();
    } catch (e) {
      print('Error deleting pelanggan: $e');
    }
  }

  // Fungsi untuk mencari produk berdasarkan kata kunci pencarian
  void searchProduk(String query) {
    setState(() {
      searchQuery = query;
      pelangganFiltered = pelanggan.where((langgan) {
        return langgan['NamaPelanggan'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }
  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: isLoading
        ? Center(
            child: LoadingAnimationWidget.twoRotatingArc(
                color: const Color.fromARGB(255, 240, 194, 209), size: 30),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  child: TextField(
                    onChanged: (query) {
                      searchPelanggan(query); // Panggil fungsi pencarian
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
              ),
              pelangganFiltered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada pelanggan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: pelangganFiltered.length, // Gunakan pelangganFiltered
                        itemBuilder: (context, index) {
                          final langgan = pelangganFiltered[index]; // Gunakan pelangganFiltered
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    langgan['NamaPelanggan'] ?? 'Pelanggan tidak tersedia',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    langgan['Alamat'] ?? 'Alamat Tidak tersedia',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    langgan['NomorTelepon'] ?? 'Tidak tersedia',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                        onPressed: () {
                                          final PelangganID = langgan['PelangganID'] ?? 0;
                                          if (PelangganID != 0) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => updatepelanggan(PelangganID: PelangganID),
                                              ),
                                            );
                                          } else {
                                            print('ID pelanggan tidak valid');
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
                                                title: const Text('Hapus Pelanggan'),
                                                content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      deletePelanggan(langgan['PelangganID']);
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
                    ),
            ],
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => insertpelanggan()),
        );
      },
      child: Icon(
        Icons.add,
        color: Colors.brown[300],
      ),
      backgroundColor: Colors.brown[600],
    ),
  );
}

// Fungsi untuk mencari pelanggan berdasarkan kata kunci pencarian
void searchPelanggan(String query) {
  setState(() {
    pelangganFiltered = pelanggan.where((pelangganItem) {
      return pelangganItem['NamaPelanggan']
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();
  });
}

}