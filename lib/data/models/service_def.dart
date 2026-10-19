import 'package:flutter/material.dart';

/// Kategori penyimpanan sandi (dipakai untuk filter di Vault).
const List<String> kCategories = [
  'Sosial Media',
  'Email',
  'Keuangan',
  'Game',
  'Belanja',
  'Kerja',
  'Streaming',
  'Lainnya',
];

/// Grup tab pada grid pemilih layanan.
const String kGroupAll = 'Semua';
const List<String> kServiceGroups = [
  'Sosial Media',
  'Email & Akun',
  'Streaming',
  'Keuangan',
  'Belanja',
  'Transportasi & Makanan',
  'Game',
  'Kerja & Produktivitas',
  'Lainnya',
];

/// Pemetaan grup layanan -> kategori sandi.
String categoryForGroup(String group) {
  switch (group) {
    case 'Sosial Media':
      return 'Sosial Media';
    case 'Email & Akun':
      return 'Email';
    case 'Streaming':
      return 'Streaming';
    case 'Keuangan':
      return 'Keuangan';
    case 'Belanja':
      return 'Belanja';
    case 'Game':
      return 'Game';
    case 'Kerja & Produktivitas':
      return 'Kerja';
    default:
      return 'Lainnya';
  }
}

/// Ikon bawaan untuk layanan kustom (konstan agar icon tree-shaking aman).
const List<IconData> kCustomIcons = [
  Icons.language_rounded,
  Icons.wifi_rounded,
  Icons.router_rounded,
  Icons.credit_card_rounded,
  Icons.key_rounded,
  Icons.shield_rounded,
  Icons.mail_rounded,
  Icons.shopping_bag_rounded,
  Icons.sports_esports_rounded,
  Icons.work_rounded,
  Icons.account_balance_rounded,
  Icons.cloud_rounded,
  Icons.home_rounded,
  Icons.school_rounded,
  Icons.favorite_rounded,
  Icons.star_rounded,
];

/// Warna pilihan untuk layanan kustom.
const List<Color> kCustomColors = [
  Color(0xFF710912),
  Color(0xFFC28D39),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFF8E24AA),
  Color(0xFFF4511E),
  Color(0xFF00897B),
  Color(0xFF546E7A),
];

/// Definisi satu layanan (bawaan katalog maupun kustom).
@immutable
class ServiceDef {
  const ServiceDef({
    required this.id,
    required this.name,
    required this.group,
    required this.color,
    this.slug,
    this.iconIndex,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String group;

  /// Nama berkas SVG di assets/icons (tanpa ekstensi). Null = pakai inisial.
  final String? slug;

  /// Warna latar squircle (ARGB).
  final int color;

  /// Indeks ke [kCustomIcons] untuk layanan kustom.
  final int? iconIndex;
  final bool isCustom;

  String get category => categoryForGroup(group);

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1);
    }
    return (parts[0][0] + parts[1][0]);
  }

  /// Layanan cadangan jika layanan sudah tidak ditemukan.
  static ServiceDef fallback(String id, String name) => ServiceDef(
        id: id,
        name: name,
        group: 'Lainnya',
        color: 0xFF546E7A,
      );
}
