import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class cetakpdf extends StatefulWidget {
  final Map cetak;
  final String PenjualanID;
  const cetakpdf({Key? key, required this.cetak, required this.PenjualanID}) : super(key: key);

  @override
  _cetakpdfState createState() => _cetakpdfState();
}

class _cetakpdfState extends State<cetakpdf> {
  @override
  Widget build(BuildContext context) {
    // Kembalikan widget kosong karena kita tidak perlu menampilkan UI di sini
    return Container();
  }
  
  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mencetak PDF saat halaman dimuat
    generateAndPrintPDF(widget.PenjualanID);
  }


  Future<void> generateAndPrintPDF(String PenjualanID) async {
    final pdf = pw.Document();
    
    // Ambil data penjualan dari Supabase
    var responseSales = await Supabase.instance.client
        .from('penjualan')
        .select('*, pelanggan(*)')
        .eq('PenjualanID', PenjualanID)
        .single();
    
    var responseSalesDetail = await Supabase.instance.client
        .from('detailpenjualan')
        .select('*, produk(*)')
        .eq('PenjualanID', int.parse(PenjualanID));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Riwayat Transaksi", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Pelanggan: ${responseSales['pelanggan']['NamaPelanggan']}", style: pw.TextStyle(fontSize: 18)),
              pw.Text("Tanggal: ${responseSales['TanggalPenjualan']}", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ["Produk", "Jumlah", "Subtotal"],
                data: responseSalesDetail.map((detail) => [
                  detail['produk']['NamaProduk'],
                  detail['JumlahProduk'].toString(),
                  detail['Subtotal'].toString()
                ]).toList(),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Total Harga: ${responseSales['TotalHarga']}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  

}