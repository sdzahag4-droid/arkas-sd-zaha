class RkasModel {
  final String id;
  final String kodeKegiatan;
  final String uraian;
  final dynamic volume;
  final String satuan;
  final dynamic hargaSatuan;
  final dynamic total;
  final String tahap;

  RkasModel({
    required this.id,
    required this.kodeKegiatan,
    required this.uraian,
    required this.volume,
    required this.satuan,
    required this.hargaSatuan,
    required this.total,
    required this.tahap,
  });

  factory RkasModel.fromJson(Map<String, dynamic> json) {
    return RkasModel(
      id: json['id'].toString(),
      kodeKegiatan: json['kode_kegiatan'].toString(),
      uraian: json['uraian'].toString(),
      volume: json['volume'],
      satuan: json['satuan'].toString(),
      hargaSatuan: json['harga_satuan'],
      total: json['total'],
      tahap: json['tahap'].toString(),
    );
  }
}