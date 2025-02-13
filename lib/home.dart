import 'package:flutter/material.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {

   // GlobalKey untuk Scaffold agar dapat membuka drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.inventory, color: Colors.white),
                child: Text('Produk',style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
              Tab(
                icon: Icon(Icons.people, color: Colors.white),
                child: Text('Pelanggan',style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
              Tab(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                child: Text('Penjualan',style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
              Tab(
                icon: Icon(Icons.account_balance_wallet, color: Colors.white),
                child: Text('Detail Penjualan',style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: Colors.brown[600],
          foregroundColor: Colors.white,
          title: const Text("D'Qasir"),
          centerTitle: true,
        ),
      ),
    );
  }
}