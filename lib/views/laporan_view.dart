import 'dart:typed_data';
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

  // Helper untuk merapikan format tanggal transaksi dari database/sheets
  String _formatTanggal(String? tglStr) {
    if (tglStr == null || tglStr.isEmpty) return '-';
    try {
      DateTime parsed = DateTime.parse(tglStr);
      return '${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year}';
    } catch (_) {
      return tglStr.split('T').first;
    }
  }

  // Helper untuk mendapatkan tanggal hari ini saat laporan di-export (Format Indonesia)
  String _getExportDate() {
    final now = DateTime.now();
    const List<String> months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${months[now.month]} ${now.year}';
  }

  // Fungsi untuk generate byte data PDF Laporan K7 / BKU
  Future<Uint8List> _generatePdfBytes(String jenisLaporan) async {
    // Ambil data BKU dan data Sekolah secara bersamaan dari Google Sheets
    List<dynamic> bkuData = await ApiService.getData('BKU');
    List<dynamic> sekolahData = await ApiService.getData('Sekolah');

    // Ambil nama kepala sekolah dan bendahara dari baris pertama sheet Sekolah
    String namaKepalaSekolah = 'Kepala Sekolah';
    String namaBendahara = 'Bendahara Sekolah';
    
    if (sekolahData.isNotEmpty) {
      namaKepalaSekolah = sekolahData[0]['kepala_sekolah']?.toString() ?? 'Kepala Sekolah';
      namaBendahara = sekolahData[0]['bendahara']?.toString() ?? 'Bendahara Sekolah';
    }

    final pdf = pw.Document();
    final String tanggalExport = _getExportDate(); // Tanggal real-time hari ini

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
                  _formatTanggal(item['tanggal']?.toString()),
                  item['nomor_bukti']?.toString() ?? '-',
                  item['uraian']?.toString() ?? '-',
                  'Rp ${item['penerimaan'] ?? 0}',
                  'Rp ${item['pengeluaran'] ?? 0}',
                ];
              }),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5))),
            ),
            pw.SizedBox(height: 40),
            // TANDA TANGAN (Menggunakan variabel tanggalExport secara dinamis)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Mengetahui,\nKepala SD Zainul Hasan Genggong', textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: 45),
                    pw.Text(namaKepalaSekolah, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('NIP. ........................................', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Genggong, $tanggalExport\nBendahara BOS', textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: 45),
                    pw.Text(namaBendahara, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('NIP. ........................................', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Membuka Halaman Preview dengan aman
  void _openPdfPreview(String jenisLaporan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Preview Laporan $jenisLaporan'),
            backgroundColor: const Color(0xFF1E3A8A),
          ),
          body: PdfPreview(
            build: (format) => _generatePdfBytes(jenisLaporan),
            initialPageFormat: PdfPageFormat.a4,
            canChangeOrientation: false,
            canChangePageFormat: false,
            allowSharing: false,
            allowPrinting: true,
          ),
        ),
      ),
    );
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
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
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
                        () => _openPdfPreview('K7 (BUKU KAS UMUM)'),
                      ),
                      _buildReportCard(
                        'Format K7a (Buku Pembantu Bank)',
                        'Laporan khusus transaksi melalui rekening bank sekolah.',
                        Icons.account_balance,
                        Colors.green,
                        () => _openPdfPreview('K7a (PEMBANTU BANK)'),
                      ),
                      _buildReportCard(
                        'Format K7b (Buku Pembantu Pajak)',
                        'Rekapitulasi pungutan dan penyetoran pajak PPh / PPN.',
                        Icons.receipt_long,
                        Colors.orange,
                        () => _openPdfPreview('K7b (PEMBANTU PAJAK)'),
                      ),
                      _buildReportCard(
                        'Rekapitulasi Penggunaan Dana',
                        'Ringkasan penggunaan dana BOS per komponen kegiatan.',
                        Icons.pie_chart,
                        Colors.purple,
                        () => _openPdfPreview('REKAPITULASI DANA BOS'),
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