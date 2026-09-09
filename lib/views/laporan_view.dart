import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/api_service.dart';

class LaporanView extends StatefulWidget {
  const LaporanView({super.key});

  @override
  State<LaporanView> createState() => _LaporanViewState();
}

class _LaporanViewState extends State<LaporanView> {
  bool _isLoading = false;

  // Fungsi untuk generate dan preview PDF Laporan K7 / BKU
  Future<void> _generatePdfReport(String jenisLaporan) async {
    setState(() => _isLoading = true);
    try {
      // Ambil data BKU dari Google Sheets
      List<dynamic> bkuData = await ApiService.getData('BKU');

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // KOP LAPORAN
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('PEMERINTAH KABUPATEN PROBOLINGGO', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('DINAS PENDIDIKAN DAN KEBUDAYAAN', style: const pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 4),
                    pw.Text('SD ZAINUL HASAN GENGGONG', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Divider(thickness: 2),
                    pw.SizedBox(height: 8),
                    pw.Center(
                      child: pw.Text(
                        'LAPORAN $jenisLaporan DANA BOS',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.SizedBox(height: 16),
                  ],
                ),
              ),
              // TABEL DATA TRANSAKSI
              pw.Table.fromTextArray(
                headers: ['No', 'Tanggal', 'No. Bukti', 'Uraian', 'Penerimaan', 'Pengeluaran'],
                data: List.generate(bkuData.length, (index) {
                  var item = bkuData[index];
                  return [
                    '${index + 1}',
                    item['tanggal'].toString(),
                    item['nomor_bukti'].toString(),
                    item['uraian'].toString(),
                    'Rp ${item['penerimaan']}',
                    'Rp ${item['pengeluaran']}',
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5))),
              ),
              pw.SizedBox(height: 40),
              // TANDA TANGAN
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Mengetahui,\nKepala SD Zainul Hasan Genggong', textAlign: pw.TextAlign.center),
                      pw.SizedBox(height: 50),
                      pw.Text('( Kepala Sekolah )', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('NIP. ........................................'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Genggong, ............................ 2026\nBendahara BOS', textAlign: pw.TextAlign.center),
                      pw.SizedBox(height: 50),
                      pw.Text('( Bendahara Sekolah )', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('NIP. ........................................'),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      // Tampilkan jendela Print / Preview PDF bawaan Windows
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Laporan_$jenisLaporan.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat laporan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pusat Pelaporan & Cetak Dokumen',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 4),
          const Text(
            'SD Zainul Hasan Genggong — Cetak Laporan Format Resmi (K7, Pajak, & Rekapitulasi)',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    children: [
                      _buildReportCard(
                        'Format K7 (Buku Kas Umum)',
                        'Laporan kronologis seluruh transaksi penerimaan dan pengeluaran.',
                        Icons.menu_book,
                        Colors.blue,
                        () => _generatePdfReport('K7 (BUKU KAS UMUM)'),
                      ),
                      _buildReportCard(
                        'Format K7a (Buku Pembantu Bank)',
                        'Laporan khusus transaksi melalui rekening bank sekolah.',
                        Icons.account_balance,
                        Colors.green,
                        () => _generatePdfReport('K7a (PEMBANTU BANK)'),
                      ),
                      _buildReportCard(
                        'Format K7b (Buku Pembantu Pajak)',
                        'Rekapitulasi pungutan dan penyetoran pajak PPh / PPN.',
                        Icons.receipt_long,
                        Colors.orange,
                        () => _generatePdfReport('K7b (PEMBANTU PAJAK)'),
                      ),
                      _buildReportCard(
                        'Rekapitulasi Penggunaan Dana',
                        'Ringkasan penggunaan dana BOS per komponen kegiatan.',
                        Icons.pie_chart,
                        Colors.purple,
                        () => _generatePdfReport('REKAPITULASI DANA BOS'),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.print, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}