import 'package:flutter/material.dart';
import 'rkas_view.dart';
import 'bku_view.dart';
import 'laporan_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const RkasView(),
    const BkuView(),
    const LaporanView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigasi Kiri
          Container(
            width: 260,
            color: const Color(0xFF1E3A8A), // Biru Profesional ala Dinas/Sekolah
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ARKAS SD ZAHA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'SD Zainul Hasan Genggong',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNavItem(0, Icons.dashboard, 'Dashboard Utama'),
                      _buildNavItem(1, Icons.account_balance_wallet, 'Kelola RKAS'),
                      _buildNavItem(2, Icons.book, 'Buku Kas Umum (BKU)'),
                      _buildNavItem(3, Icons.print, 'Laporan (K7, Pajak dll)'),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Versi 1.0.0 (Windows Desktop)',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          // Area Konten Utama di Kanan
          Expanded(
            child: Container(
              color: const Color(0xFFF3F4F6),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.amberAccent : Colors.white70, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Halaman Depan / Dashboard Ringkasan
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Datang di Aplikasi ARKAS',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 8),
          const Text(
            'SD Zainul Hasan Genggong — Manajemen Dana BOS & Pelaporan Transparan',
            style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoCard('Pagu Dana BOS', 'Rp 0', Icons.wallet, Colors.blue),
              const SizedBox(width: 16),
              _buildInfoCard('Total Realisasi Belanja', 'Rp 0', Icons.shopping_cart, Colors.green),
              const SizedBox(width: 16),
              _buildInfoCard('Sisa Saldo Kas', 'Rp 0', Icons.account_balance, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}