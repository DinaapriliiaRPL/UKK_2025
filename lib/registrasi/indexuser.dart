import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ukk_dinakasir/home.dart';
import 'package:ukk_dinakasir/registrasi/insertuser.dart';
import 'package:ukk_dinakasir/registrasi/updateuser.dart';

class userpage extends StatefulWidget {
  const userpage({super.key});

  @override
  State<userpage> createState() => _userpageState();
}

class _userpageState extends State<userpage> {
  List<Map<String, dynamic>> user = [];
  List<Map<String, dynamic>> userFiltered = []; //Variabel untuk menyimpan hasil pencarian

  bool isLoading = true;

  String searchQuery = ""; //variabel untuk menyimpan kata kunci pencarian

  @override
  void initState() {
    super.initState();
    fetchuser();
  }

  Future<void> deleteuser(int id) async {
    try {
      await Supabase.instance.client
      .from('user')
      .delete()
      .eq('id', id);
      fetchuser();
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> fetchuser() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Supabase.instance.client.from('user').select();
      setState(() {
        user = List<Map<String, dynamic>>.from(response);
        userFiltered = user;
        isLoading = false;
      });
    } catch (e) {
      print('error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk mencari produk berdasarkan kata kunci pencarian
  void searchProduk(String query) {
    setState(() {
      searchQuery = query;
      userFiltered = user.where((usr) {
        return usr['username'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.brown[600],
      title: const Text("User D'Qasir", 
        style: TextStyle(color: Colors.white)),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.white), 
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => homepage())
          );
        } 
      ),
    ),
    body: isLoading
      ? Center(
          child: LoadingAnimationWidget.twoRotatingArc(color: Colors.grey, size: 30),
        )
      : Column(
          children: [
            // Kolom Pencarian
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Expanded(
                child: TextField(
                  onChanged: (query) {
                    searchUser(query); // Panggil fungsi pencarian
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
            // // Bagian Header
            // Card(
            //   margin: const EdgeInsets.all(10),
            //   color: Colors.brown[50],
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //     child: Row(
            //       children: const [
            //         Expanded(flex: 2, child: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
            //         Expanded(flex: 2, child: Text('Password', style: TextStyle(fontWeight: FontWeight.bold))),
            //         Expanded(flex: 1, child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
            //         Expanded(flex: 1, child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
            //       ],
            //     ),
            //   ),
            // ),
            // User cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: userFiltered.length, // Gunakan userFiltered
                itemBuilder: (context, index) {
                  final userdata = userFiltered[index]; // Gunakan userFiltered
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(userdata['username'] ?? '')),
                          Expanded(flex: 2, child: Text(userdata['password'] ?? '')),
                          Expanded(flex: 1, child: Text(userdata['role'] ?? '')),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    final id = userdata['id'] ?? 0;
                                    if (id != 0) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => updateuser(id: id),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Hapus user'),
                                          content: const Text('Apakah anda yakin menghapus user?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                deleteuser(userdata['id']);
                                              },
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          )
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
          MaterialPageRoute(builder: (context) => insertuser()),
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

// Fungsi untuk mencari user berdasarkan kata kunci pencarian
void searchUser(String query) {
  setState(() {
    userFiltered = user.where((userdata) {
      return userdata['username']
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();
  });
}

}