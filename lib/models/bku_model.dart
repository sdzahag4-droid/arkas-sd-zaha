class BkuModel {
  final String id;
  final String tanggal;
  final String nomorBukti;
  final String uraian;
  final dynamic penerimaan;
  final dynamic pengeluaran;
  final String jenisTransaksi;
  final String metode;
  final String pajak;

  BkuModel({
    required this.id,
    required this.tanggal,
    required this.nomorBukti,
    required this.uraian,
    required this.penerimaan,
    required this.pengeluaran,
    required this.jenisTransaksi,
    required this.metode,
    required this.pajak,
  });

  factory BkuModel.fromJson(Map<String, dynamic> json) {
    return BkuModel(
      id: json['id'].toString(),
      tanggal: json['tanggal'].toString(),
      nomorBukti: json['nomor_bukti'].toString(),
      uraian: json['uraian'].toString(),
      penerimaan: json['penerimaan'],
      pengeluaran: json['pengeluaran'],
      jenisTransaksi: json['jenis_transaksi'].toString(),
      metode: json['metode'].toString(),
      pajak: json['pajak'].toString(),
    );
  }
}