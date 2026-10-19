import 'dart:convert';
import 'dart:math';

import 'service_def.dart';

/// Satu entri sandi yang tersimpan di vault.
class Credential {
  const Credential({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.username,
    required this.password,
    this.url = '',
    this.notes = '',
    this.category = 'Lainnya',
    this.favorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String serviceId;
  final String serviceName;
  final String username;
  final String password;
  final String url;
  final String notes;
  final String category;
  final bool favorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  static String newId() {
    final r = Random.secure();
    return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
  }

  Credential copyWith({
    String? serviceId,
    String? serviceName,
    String? username,
    String? password,
    String? url,
    String? notes,
    String? category,
    bool? favorite,
    DateTime? updatedAt,
  }) {
    return Credential(
      id: id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'username': username,
        'password': password,
        'url': url,
        'notes': notes,
        'category': category,
        'favorite': favorite,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Credential.fromJson(Map<String, dynamic> j) {
    final cat = (j['category'] as String?) ?? 'Lainnya';
    return Credential(
      id: j['id'] as String,
      serviceId: j['serviceId'] as String,
      serviceName: j['serviceName'] as String,
      username: (j['username'] as String?) ?? '',
      password: (j['password'] as String?) ?? '',
      url: (j['url'] as String?) ?? '',
      notes: (j['notes'] as String?) ?? '',
      category: kCategories.contains(cat) ? cat : 'Lainnya',
      favorite: (j['favorite'] as bool?) ?? false,
      createdAt: DateTime.parse(j['createdAt'] as String),
      updatedAt: DateTime.parse(j['updatedAt'] as String),
    );
  }
}

/// Layanan buatan pengguna.
class CustomService {
  const CustomService({
    required this.id,
    required this.name,
    required this.iconIndex,
    required this.color,
  });

  final String id;
  final String name;
  final int iconIndex;
  final int color;

  ServiceDef toDef() => ServiceDef(
        id: id,
        name: name,
        group: 'Lainnya',
        color: color,
        iconIndex: iconIndex,
        isCustom: true,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'iconIndex': iconIndex, 'color': color};

  factory CustomService.fromJson(Map<String, dynamic> j) => CustomService(
        id: j['id'] as String,
        name: j['name'] as String,
        iconIndex: (j['iconIndex'] as num).toInt(),
        color: (j['color'] as num).toInt(),
      );
}

/// Isi vault yang dienkripsi sebagai satu dokumen JSON.
class VaultData {
  const VaultData({this.credentials = const [], this.customServices = const []});

  final List<Credential> credentials;
  final List<CustomService> customServices;

  VaultData copyWith(
          {List<Credential>? credentials,
          List<CustomService>? customServices}) =>
      VaultData(
        credentials: credentials ?? this.credentials,
        customServices: customServices ?? this.customServices,
      );

  List<int> encode() => utf8.encode(jsonEncode({
        'v': 1,
        'credentials': credentials.map((e) => e.toJson()).toList(),
        'customServices': customServices.map((e) => e.toJson()).toList(),
      }));

  factory VaultData.decode(List<int> bytes) {
    final j = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return VaultData(
      credentials: ((j['credentials'] as List?) ?? [])
          .map((e) => Credential.fromJson(e as Map<String, dynamic>))
          .toList(),
      customServices: ((j['customServices'] as List?) ?? [])
          .map((e) => CustomService.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
