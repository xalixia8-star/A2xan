import '../models/service_def.dart';

/// Katalog layanan bawaan.
/// `slug` = nama berkas SVG simple-icons (diunduh tools/bootstrap.sh).
/// Layanan tanpa slug (atau yang SVG-nya tidak tersedia) memakai inisial huruf.
const String _sm = 'Sosial Media';
const String _em = 'Email & Akun';
const String _st = 'Streaming';
const String _fi = 'Keuangan';
const String _sh = 'Belanja';
const String _tr = 'Transportasi & Makanan';
const String _gm = 'Game';
const String _wk = 'Kerja & Produktivitas';
const String _ot = 'Lainnya';

const List<ServiceDef> kServiceCatalog = [
  // Sosial Media
  ServiceDef(id: 'facebook', name: 'Facebook', group: _sm, slug: 'facebook', color: 0xFF1877F2),
  ServiceDef(id: 'instagram', name: 'Instagram', group: _sm, slug: 'instagram', color: 0xFFC13584),
  ServiceDef(id: 'x', name: 'X (Twitter)', group: _sm, slug: 'x', color: 0xFF000000),
  ServiceDef(id: 'tiktok', name: 'TikTok', group: _sm, slug: 'tiktok', color: 0xFF000000),
  ServiceDef(id: 'snapchat', name: 'Snapchat', group: _sm, slug: 'snapchat', color: 0xFFFFFC00),
  ServiceDef(id: 'linkedin', name: 'LinkedIn', group: _sm, slug: 'linkedin', color: 0xFF0A66C2),
  ServiceDef(id: 'pinterest', name: 'Pinterest', group: _sm, slug: 'pinterest', color: 0xFFE60023),
  ServiceDef(id: 'reddit', name: 'Reddit', group: _sm, slug: 'reddit', color: 0xFFFF4500),
  ServiceDef(id: 'threads', name: 'Threads', group: _sm, slug: 'threads', color: 0xFF000000),
  ServiceDef(id: 'tumblr', name: 'Tumblr', group: _sm, slug: 'tumblr', color: 0xFF36465D),
  ServiceDef(id: 'bereal', name: 'BeReal', group: _sm, slug: 'bereal', color: 0xFF000000),
  ServiceDef(id: 'telegram', name: 'Telegram', group: _sm, slug: 'telegram', color: 0xFF26A5E4),
  ServiceDef(id: 'whatsapp', name: 'WhatsApp', group: _sm, slug: 'whatsapp', color: 0xFF25D366),
  ServiceDef(id: 'line', name: 'Line', group: _sm, slug: 'line', color: 0xFF00C300),
  ServiceDef(id: 'discord', name: 'Discord', group: _sm, slug: 'discord', color: 0xFF5865F2),
  ServiceDef(id: 'wechat', name: 'WeChat', group: _sm, slug: 'wechat', color: 0xFF07C160),
  ServiceDef(id: 'signal', name: 'Signal', group: _sm, slug: 'signal', color: 0xFF3A76F0),
  ServiceDef(id: 'viber', name: 'Viber', group: _sm, slug: 'viber', color: 0xFF7360F2),
  ServiceDef(id: 'kakao', name: 'Kakao', group: _sm, slug: 'kakaotalk', color: 0xFFFFCD00),
  ServiceDef(id: 'twitch', name: 'Twitch', group: _sm, slug: 'twitch', color: 0xFF9146FF),

  // Email & Akun
  ServiceDef(id: 'google', name: 'Google', group: _em, slug: 'google', color: 0xFF4285F4),
  ServiceDef(id: 'gmail', name: 'Gmail', group: _em, slug: 'gmail', color: 0xFFEA4335),
  ServiceDef(id: 'apple', name: 'Apple ID / iCloud', group: _em, slug: 'icloud', color: 0xFF3693F3),
  ServiceDef(id: 'microsoft', name: 'Microsoft', group: _em, slug: 'microsoft', color: 0xFF5E5E5E),
  ServiceDef(id: 'outlook', name: 'Outlook', group: _em, slug: 'microsoftoutlook', color: 0xFF0078D4),
  ServiceDef(id: 'yahoo', name: 'Yahoo', group: _em, slug: 'yahoo', color: 0xFF6001D2),
  ServiceDef(id: 'protonmail', name: 'ProtonMail', group: _em, slug: 'protonmail', color: 0xFF6D4AFF),

  // Streaming
  ServiceDef(id: 'youtube', name: 'YouTube', group: _st, slug: 'youtube', color: 0xFFFF0000),
  ServiceDef(id: 'netflix', name: 'Netflix', group: _st, slug: 'netflix', color: 0xFFE50914),
  ServiceDef(id: 'spotify', name: 'Spotify', group: _st, slug: 'spotify', color: 0xFF1DB954),
  ServiceDef(id: 'disneyplus', name: 'Disney+', group: _st, slug: 'disneyplus', color: 0xFF113CCF),
  ServiceDef(id: 'primevideo', name: 'Prime Video', group: _st, slug: 'primevideo', color: 0xFF00A8E1),
  ServiceDef(id: 'hbomax', name: 'HBO / Max', group: _st, slug: 'hbomax', color: 0xFF5822B4),
  ServiceDef(id: 'vidio', name: 'Vidio', group: _st, color: 0xFFE4002B),
  ServiceDef(id: 'viu', name: 'Viu', group: _st, color: 0xFFF9B500),
  ServiceDef(id: 'wetv', name: 'WeTV', group: _st, color: 0xFFFF6A00),
  ServiceDef(id: 'iqiyi', name: 'iQIYI', group: _st, slug: 'iqiyi', color: 0xFF00CC36),
  ServiceDef(id: 'applemusic', name: 'Apple Music', group: _st, slug: 'applemusic', color: 0xFFFA243C),
  ServiceDef(id: 'youtubemusic', name: 'YouTube Music', group: _st, slug: 'youtubemusic', color: 0xFFFF0000),
  ServiceDef(id: 'joox', name: 'Joox', group: _st, color: 0xFF1ED760),

  // Keuangan
  ServiceDef(id: 'bca', name: 'BCA', group: _fi, color: 0xFF0066AE),
  ServiceDef(id: 'mandiri', name: 'Mandiri', group: _fi, color: 0xFF003D79),
  ServiceDef(id: 'bni', name: 'BNI', group: _fi, color: 0xFFF37021),
  ServiceDef(id: 'bri', name: 'BRI', group: _fi, color: 0xFF00529C),
  ServiceDef(id: 'cimb', name: 'CIMB Niaga', group: _fi, color: 0xFF7E0C1E),
  ServiceDef(id: 'jago', name: 'Jago', group: _fi, color: 0xFFFFB800),
  ServiceDef(id: 'seabank', name: 'SeaBank', group: _fi, color: 0xFFFF5A1F),
  ServiceDef(id: 'blu', name: 'Blu', group: _fi, color: 0xFF0A5CFF),
  ServiceDef(id: 'gopay', name: 'GoPay', group: _fi, color: 0xFF00AED6),
  ServiceDef(id: 'ovo', name: 'OVO', group: _fi, color: 0xFF4C2A86),
  ServiceDef(id: 'dana', name: 'DANA', group: _fi, color: 0xFF118EEA),
  ServiceDef(id: 'shopeepay', name: 'ShopeePay', group: _fi, color: 0xFFEE4D2D),
  ServiceDef(id: 'linkaja', name: 'LinkAja', group: _fi, color: 0xFFE31E24),
  ServiceDef(id: 'paypal', name: 'PayPal', group: _fi, slug: 'paypal', color: 0xFF003087),
  ServiceDef(id: 'wise', name: 'Wise', group: _fi, slug: 'wise', color: 0xFF9FE870),
  ServiceDef(id: 'binance', name: 'Binance', group: _fi, slug: 'binance', color: 0xFFF3BA2F),
  ServiceDef(id: 'indodax', name: 'Indodax', group: _fi, color: 0xFF1B6EF3),
  ServiceDef(id: 'tokocrypto', name: 'Tokocrypto', group: _fi, color: 0xFF1D6BFF),

  // Belanja
  ServiceDef(id: 'shopee', name: 'Shopee', group: _sh, slug: 'shopee', color: 0xFFEE4D2D),
  ServiceDef(id: 'tokopedia', name: 'Tokopedia', group: _sh, slug: 'tokopedia', color: 0xFF03AC0E),
  ServiceDef(id: 'lazada', name: 'Lazada', group: _sh, slug: 'lazada', color: 0xFF0F146D),
  ServiceDef(id: 'bukalapak', name: 'Bukalapak', group: _sh, color: 0xFFE31E52),
  ServiceDef(id: 'blibli', name: 'Blibli', group: _sh, color: 0xFF0095DA),
  ServiceDef(id: 'amazon', name: 'Amazon', group: _sh, slug: 'amazon', color: 0xFFFF9900),
  ServiceDef(id: 'aliexpress', name: 'AliExpress', group: _sh, slug: 'aliexpress', color: 0xFFE62E04),
  ServiceDef(id: 'ebay', name: 'eBay', group: _sh, slug: 'ebay', color: 0xFFE53238),
  ServiceDef(id: 'temu', name: 'Temu', group: _sh, slug: 'temu', color: 0xFFFB7701),
  ServiceDef(id: 'zalora', name: 'Zalora', group: _sh, slug: 'zalando', color: 0xFF1A1A1A),
  ServiceDef(id: 'traveloka', name: 'Traveloka', group: _sh, slug: 'traveloka', color: 0xFF0770E3),
  ServiceDef(id: 'tiketcom', name: 'tiket.com', group: _sh, color: 0xFF0064D2),

  // Transportasi & Makanan
  ServiceDef(id: 'gojek', name: 'Gojek', group: _tr, slug: 'gojek', color: 0xFF00AA13),
  ServiceDef(id: 'grab', name: 'Grab', group: _tr, slug: 'grab', color: 0xFF00B14F),
  ServiceDef(id: 'maxim', name: 'Maxim', group: _tr, color: 0xFFFFCC00),
  ServiceDef(id: 'indrive', name: 'inDrive', group: _tr, color: 0xFFC1F11D),
  ServiceDef(id: 'gofood', name: 'GoFood', group: _tr, color: 0xFFEE2737),
  ServiceDef(id: 'grabfood', name: 'GrabFood', group: _tr, color: 0xFF00B14F),
  ServiceDef(id: 'shopeefood', name: 'ShopeeFood', group: _tr, color: 0xFFEE4D2D),

  // Game
  ServiceDef(id: 'steam', name: 'Steam', group: _gm, slug: 'steam', color: 0xFF1B2838),
  ServiceDef(id: 'epicgames', name: 'Epic Games', group: _gm, slug: 'epicgames', color: 0xFF2F2D2E),
  ServiceDef(id: 'playstation', name: 'PlayStation', group: _gm, slug: 'playstation', color: 0xFF003791),
  ServiceDef(id: 'xbox', name: 'Xbox', group: _gm, slug: 'xbox', color: 0xFF107C10),
  ServiceDef(id: 'nintendo', name: 'Nintendo', group: _gm, slug: 'nintendo', color: 0xFFE60012),
  ServiceDef(id: 'roblox', name: 'Roblox', group: _gm, slug: 'roblox', color: 0xFF1F1F1F),
  ServiceDef(id: 'minecraft', name: 'Minecraft', group: _gm, slug: 'minecraft', color: 0xFF62B47A),
  ServiceDef(id: 'mlbb', name: 'Mobile Legends', group: _gm, color: 0xFF1D3F8A),
  ServiceDef(id: 'freefire', name: 'Free Fire', group: _gm, color: 0xFFF58220),
  ServiceDef(id: 'pubgm', name: 'PUBG Mobile', group: _gm, slug: 'pubg', color: 0xFFF2A900),
  ServiceDef(id: 'genshin', name: 'Genshin Impact', group: _gm, color: 0xFF3E5C9A),
  ServiceDef(id: 'valorant', name: 'Valorant', group: _gm, slug: 'valorant', color: 0xFFFF4655),
  ServiceDef(id: 'riotgames', name: 'Riot Games', group: _gm, slug: 'riotgames', color: 0xFFD32936),
  ServiceDef(id: 'ea', name: 'EA', group: _gm, slug: 'ea', color: 0xFFFF4747),
  ServiceDef(id: 'ubisoft', name: 'Ubisoft', group: _gm, slug: 'ubisoft', color: 0xFF0070FF),
  ServiceDef(id: 'battlenet', name: 'Battle.net', group: _gm, slug: 'battledotnet', color: 0xFF148EFF),

  // Kerja & Produktivitas
  ServiceDef(id: 'github', name: 'GitHub', group: _wk, slug: 'github', color: 0xFF181717),
  ServiceDef(id: 'gitlab', name: 'GitLab', group: _wk, slug: 'gitlab', color: 0xFFFC6D26),
  ServiceDef(id: 'slack', name: 'Slack', group: _wk, slug: 'slack', color: 0xFF4A154B),
  ServiceDef(id: 'zoom', name: 'Zoom', group: _wk, slug: 'zoom', color: 0xFF0B5CFF),
  ServiceDef(id: 'teams', name: 'Microsoft Teams', group: _wk, slug: 'microsoftteams', color: 0xFF6264A7),
  ServiceDef(id: 'notion', name: 'Notion', group: _wk, slug: 'notion', color: 0xFF000000),
  ServiceDef(id: 'trello', name: 'Trello', group: _wk, slug: 'trello', color: 0xFF0052CC),
  ServiceDef(id: 'figma', name: 'Figma', group: _wk, slug: 'figma', color: 0xFF1E1E1E),
  ServiceDef(id: 'canva', name: 'Canva', group: _wk, slug: 'canva', color: 0xFF00C4CC),
  ServiceDef(id: 'adobe', name: 'Adobe', group: _wk, slug: 'adobe', color: 0xFFEB1000),
  ServiceDef(id: 'dropbox', name: 'Dropbox', group: _wk, slug: 'dropbox', color: 0xFF0061FF),
  ServiceDef(id: 'googledrive', name: 'Google Drive', group: _wk, slug: 'googledrive', color: 0xFF1FA463),
  ServiceDef(id: 'onedrive', name: 'OneDrive', group: _wk, slug: 'microsoftonedrive', color: 0xFF0078D4),
  ServiceDef(id: 'evernote', name: 'Evernote', group: _wk, slug: 'evernote', color: 0xFF00A82D),
  ServiceDef(id: 'jira', name: 'Jira', group: _wk, slug: 'jira', color: 0xFF0052CC),
  ServiceDef(id: 'chatgpt', name: 'ChatGPT', group: _wk, slug: 'openai', color: 0xFF10A37F),
  ServiceDef(id: 'claude', name: 'Claude', group: _wk, slug: 'anthropic', color: 0xFFD97757),

  // Lainnya (ikon Material lewat iconIndex)
  ServiceDef(id: 'wifi', name: 'WiFi', group: _ot, color: 0xFF1E88E5, iconIndex: 1),
  ServiceDef(id: 'router', name: 'Router', group: _ot, color: 0xFF546E7A, iconIndex: 2),
  ServiceDef(id: 'creditcard', name: 'Kartu Kredit', group: _ot, color: 0xFF8E24AA, iconIndex: 3),
  ServiceDef(id: 'website', name: 'Website Umum', group: _ot, color: 0xFF00897B, iconIndex: 0),
];

/// Id khusus untuk tombol "Custom" pada grid.
const String kCustomTileId = '__custom__';

final Map<String, ServiceDef> kServiceById = {
  for (final s in kServiceCatalog) s.id: s,
};

/// Daftar slug unik (dipakai tools/bootstrap.sh untuk mengunduh SVG).
Set<String> get kCatalogSlugs =>
    {for (final s in kServiceCatalog) if (s.slug != null) s.slug!};
