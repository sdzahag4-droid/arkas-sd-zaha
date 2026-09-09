import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti URL di bawah ini dengan URL Web App Google Apps Script Anda yang didapat pada Langkah 1
  static const String webAppUrl = 'https://script.google.com/macros/s/AKfycbwqhAdFmlqQ41oFW6LJuVCWAUCY6h_IPm-b03qA-Mg9qUkUo4eHMFgOsT0rBBvJOdBG/exec';

  // 1. Fungsi untuk mengambil data dari Google Sheet tertentu (RKAS, BKU, Pajak, Sekolah)
  static Future<List<dynamic>> getData(String sheetName) async {
    try {
      final url = Uri.parse('$webAppUrl?sheet=$sheetName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat data');
        }
      } else {
        throw Exception('Gagal terhubung ke server (Error: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // 2. Fungsi untuk menambah data baru ke Google Sheet
  static Future<bool> addData(String sheetName, Map<String, dynamic> rowData) async {
    try {
      final url = Uri.parse(webAppUrl);
      final body = jsonEncode({
        'sheet': sheetName,
        'action': 'add',
        'data': rowData,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error saat menambah data: $e');
      return false;
    }
  }
}