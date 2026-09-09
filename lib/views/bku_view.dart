import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BkuView extends StatefulWidget {
  const BkuView({super.key});

  @override
  State<BkuView> createState() => _BkuViewState();
}

class _BkuViewState extends State<BkuView> {
  late Future<List<dynamic>> _bkuListFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _bkuListFuture = ApiService.getData('BKU');
    });
  }

  void _showAddDialog() {
    final tanggalController = TextEditingController(text: '2026-09-09');
    final buktiController = TextEditingController();
    final uraianController = TextEditingController();
    final penerimaanController = TextEditingController(text: '0');
    final pengeluaranController = TextEditingController(text: '0');
    String metode = 'Bank';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Transaksi BKU'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tanggalController, decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)')),
                TextField(controller: buktiController, decoration: const InputDecoration(labelText: 'Nomor Bukti (Contoh: 001/BOS/IX/2026)')),
                TextField(controller: uraianController, decoration: const InputDecoration(labelText: 'Uraian Transaksi')),
                TextField(controller: penerimaanController, decoration: const InputDecoration(labelText: 'Penerimaan (Rp)'), keyboardType: TextInputType.number),
                TextField(controller: pengeluaranController, decoration: const InputDecoration(labelText: 'Pengeluaran (Rp)'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: metode,
                  items: const [
                    DropdownMenuItem(value: 'Bank', child: Text('Bank (Transfer/Non-Tunai)')),
                    DropdownMenuItem(value: 'Tunai', child: Text('Tunai')),
                  ],
                  onChanged: (val) => metode = val!,
                  decoration: const InputDecoration(labelText: 'Metode Pembayaran'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> newData = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'tanggal': tanggalController.text,
                'nomor_bukti': buktiController.text,
                'uraian': uraianController.text,
                'penerimaan': double.tryParse(penerimaanController.text) ?? 0,
                'pengeluaran': double.tryParse(pengeluaranController.text) ?? 0,
                'jenis_transaksi': (double.tryParse(penerimaanController.text) ?? 0) > 0 ? 'Masuk' : 'Keluar',
                'metode': metode,
                'pajak': 'Belum',
              };

              Navigator.pop(context);
              bool success = await ApiService.addData('BKU', newData);
              if (success) {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menambah transaksi BKU')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menambah transaksi BKU')));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buku Kas Umum (BKU)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                  SizedBox(height: 4),
                  Text('Pencatatan harian penerimaan dan pengeluaran dana BOS', style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add),
                label: const Text('Catat Transaksi'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
              child: FutureBuilder<List<dynamic>>(
                future: _bkuListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada catatan BKU. Silakan tambah transaksi.'));
                  }

                  final list = snapshot.data!;
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      bool isMasuk = item['jenis_transaksi'] == 'Masuk';
                      return ListTile(
                        leading: Icon(isMasuk ? Icons.arrow_downward : Icons.arrow_upward, color: isMasuk ? Colors.green : Colors.red),
                        title: Text('${item['tanggal']} — ${item['uraian']}'),
                        subtitle: Text('Bukti: ${item['nomor_bukti']} | Metode: ${item['metode']}'),
                        trailing: Text(
                          '${isMasuk ? "+" : "-"} Rp ${isMasuk ? item['penerimaan'] : item['pengeluaran']}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: isMasuk ? Colors.green : Colors.red),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}