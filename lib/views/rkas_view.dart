import 'package:flutter/material.dart';
import '../models/rkas_model.dart';
import '../services/api_service.dart';

class RkasView extends StatefulWidget {
  const RkasView({super.key});

  @override
  State<RkasView> createState() => _RkasViewState();
}

class _RkasViewState extends State<RkasView> {
  late Future<List<dynamic>> _rkasListFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _rkasListFuture = ApiService.getData('RKAS');
    });
  }

  // Dialog untuk Tambah Data RKAS
  void _showAddDialog() {
    final kodeController = TextEditingController();
    final uraianController = TextEditingController();
    final volumeController = TextEditingController();
    final satuanController = TextEditingController();
    final hargaController = TextEditingController();
    String selectedTahap = 'Tahap 1';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Rencana Kegiatan (RKAS)'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: kodeController, decoration: const InputDecoration(labelText: 'Kode Kegiatan (Contoh: 5.1.2)')),
                TextField(controller: uraianController, decoration: const InputDecoration(labelText: 'Uraian Kegiatan / Belanja')),
                TextField(controller: volumeController, decoration: const InputDecoration(labelText: 'Volume'), keyboardType: TextInputType.number),
                TextField(controller: satuanController, decoration: const InputDecoration(labelText: 'Satuan (Contoh: Buah, Orang, Bulan)')),
                TextField(controller: hargaController, decoration: const InputDecoration(labelText: 'Harga Satuan (Rp)'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTahap,
                  items: const [
                    DropdownMenuItem(value: 'Tahap 1', child: Text('Tahap 1')),
                    DropdownMenuItem(value: 'Tahap 2', child: Text('Tahap 2')),
                  ],
                  onChanged: (val) => selectedTahap = val!,
                  decoration: const InputDecoration(labelText: 'Pilih Tahap BOS'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              double vol = double.tryParse(volumeController.text) ?? 0;
              double harga = double.tryParse(hargaController.text) ?? 0;
              double total = vol * harga;

              Map<String, dynamic> newData = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'kode_kegiatan': kodeController.text,
                'uraian': uraianController.text,
                'volume': vol,
                'satuan': satuanController.text,
                'harga_satuan': harga,
                'total': total,
                'tahap': selectedTahap,
              };

              Navigator.pop(context);
              bool success = await ApiService.addData('RKAS', newData);
              if (success) {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menambah RKAS')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menambah RKAS')));
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
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelola RKAS (Rencana Kegiatan)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                  SizedBox(height: 4),
                  Text('SD Zainul Hasan Genggong — Anggaran Dana BOS', style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add),
                label: const Text('Tambah RKAS'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
              child: FutureBuilder<List<dynamic>>(
                future: _rkasListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada data RKAS. Silakan tambah data.'));
                  }

                  final list = snapshot.data!;
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text('${item['kode_kegiatan']} - ${item['uraian']}'),
                        subtitle: Text('Volume: ${item['volume']} ${item['satuan']} | Tahap: ${item['tahap']}'),
                        trailing: Text('Rp ${item['total']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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