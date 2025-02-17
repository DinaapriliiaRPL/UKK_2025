import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_dinakasir/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://etbpvgqmtorgwrhhnkpl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0YnB2Z3FtdG9yZ3dyaGhua3BsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MDg4NTUsImV4cCI6MjA1NDk4NDg1NX0.BxyoYtqMhu_ERiFedX0NMdpxeazFjJivY2u-Qdj_xdY'
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.orange.shade100,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, colors:[
              Color(0xFF6D4C41),
              Color(0XFF8D6E63),
              Color(0xFFBCAAA4)
            ]),
          ),
        
      
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(160.0),
                  child: Image.asset(
                  'assets/image/bobaaaaa.png',
                  height: 250,
                  width: 150,
                  fit: BoxFit.cover),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Times UBoba',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'segerrrr',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[10],
                minimumSize: Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => loginpage(),
                  ),
                );
              },
              child: Text('Login', style: TextStyle(fontSize: 17, color: Colors.black)),
            ),
          ],
        ),
      ),
      )
      );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: Container(
  //         padding: EdgeInsets.symmetric(vertical: 20),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(begin: Alignment.topCenter, colors:[
  //             Color(0xFF6D4C41),
  //             Color(0XFF8D6E63),
  //             Color(0xFFBCAAA4)
  //           ]),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Center(
  //               child: Padding(
  //                 padding: EdgeInsets.all(20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: <Widget>[
  //                     Text(
  //                       "WELCOME",
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 30,
  //                         fontWeight: FontWeight.bold,
  //                         fontFamily: 'Georgea'
  //                       ),
  //                     ),
  //                     Text(
  //                       "D'Qasir",
  //                        style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 15
  //                       ),
  //                     ),
  //                     Image.asset(
  //                       'assets/image/boba.png',
  //                       height: 300,
  //                       width: 500,
  //                     )
  //                   ],
  //                 )
  //               )
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(50.0),
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.push(
  //                     context, 
  //                     MaterialPageRoute(
  //                       builder: (context) => loginpage(),
  //                     ),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.white,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   minimumSize: Size(double.infinity, 50),
  //                 ),
  //                 child: Text(
  //                   'Login',
  //                   style: TextStyle(
  //                     color: Colors.black,
  //                     fontSize: 15,
  //                     fontWeight: FontWeight.bold),
  //                 ),
  //               ),
                
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}