/// Typed catalog of commonly edited `openttd.cfg` keys.
///
/// Only well-established keys live here; everything else stays editable via
/// the raw view. Labels/docs are bilingual (zh source, en mirror).
class CatalogEntry {
  const CatalogEntry({
    required this.section,
    required this.key,
    required this.type,
    this.options = const [],
    this.min,
    this.max,
    required this.labelZh,
    required this.labelEn,
    required this.docZh,
    required this.docEn,
  });

  final String section;
  final String key;
  final CatalogType type;
  final List<String> options;
  final int? min;
  final int? max;
  final String labelZh;
  final String labelEn;
  final String docZh;
  final String docEn;
}

enum CatalogType { bool_, int_, string, enum_ }

const keyCatalog = <CatalogEntry>[
  // [misc]
  CatalogEntry(
    section: 'misc', key: 'fullscreen', type: CatalogType.bool_,
    labelZh: '全屏', labelEn: 'Fullscreen',
    docZh: '以全屏模式启动游戏。', docEn: 'Start the game in fullscreen mode.',
  ),
  CatalogEntry(
    section: 'misc', key: 'video_vsync', type: CatalogType.string,
    labelZh: '垂直同步', labelEn: 'VSync',
    docZh: '垂直同步模式（true/false/编号）。', docEn: 'Vertical sync mode (true/false/number).',
  ),
  CatalogEntry(
    section: 'misc', key: 'currency', type: CatalogType.string,
    labelZh: '货币', labelEn: 'Currency',
    docZh: '游戏内显示的货币单位（如 CNY、USD、EUR）。', docEn: 'In-game currency (CNY, USD, EUR …).',
  ),
  CatalogEntry(
    section: 'misc', key: 'graphicsset', type: CatalogType.string,
    labelZh: '基础图形集', labelEn: 'Base graphics set',
    docZh: '使用的基础图形集名称（空为默认 OpenGFX）。', docEn: 'Base graphics set name (empty = OpenGFX).',
  ),
  CatalogEntry(
    section: 'misc', key: 'soundsset', type: CatalogType.string,
    labelZh: '基础音效集', labelEn: 'Base sounds set',
    docZh: '使用的基础音效集名称。', docEn: 'Base sounds set name.',
  ),
  CatalogEntry(
    section: 'misc', key: 'musicset', type: CatalogType.string,
    labelZh: '音乐集', labelEn: 'Music set',
    docZh: '使用的音乐集名称。', docEn: 'Music set name.',
  ),
  // [gui]
  CatalogEntry(
    section: 'gui', key: 'autosave', type: CatalogType.enum_,
    options: ['off', '1', '3', '6', '12'],
    labelZh: '自动保存间隔', labelEn: 'Autosave interval',
    docZh: '自动保存间隔（游戏内月份）。', docEn: 'Autosave interval in game months.',
  ),
  CatalogEntry(
    section: 'gui', key: 'autosave_on_exit', type: CatalogType.bool_,
    labelZh: '退出时自动保存', labelEn: 'Autosave on exit',
    docZh: '退出游戏时自动保存。', docEn: 'Automatically save when quitting.',
  ),
  CatalogEntry(
    section: 'gui', key: 'fast_vehicle_speed', type: CatalogType.bool_,
    labelZh: '车辆倍速', labelEn: 'Fast vehicle speed',
    docZh: '按住 Ctrl 时车辆加速。', docEn: 'Speed up vehicles while holding Ctrl.',
  ),
  // [game_creation]
  CatalogEntry(
    section: 'game_creation', key: 'year', type: CatalogType.int_,
    min: 0, max: 5000,
    labelZh: '起始年份', labelEn: 'Starting year',
    docZh: '新游戏的起始年份。', docEn: 'Starting year for new games.',
  ),
  CatalogEntry(
    section: 'game_creation', key: 'map_x', type: CatalogType.int_,
    min: 6, max: 13,
    labelZh: '地图宽度 (2^n)', labelEn: 'Map width (2^n)',
    docZh: '地图宽度，以 2 的幂表示（6=64 … 13=8192）。', docEn: 'Map width as power of two (6=64 … 13=8192).',
  ),
  CatalogEntry(
    section: 'game_creation', key: 'map_y', type: CatalogType.int_,
    min: 6, max: 13,
    labelZh: '地图高度 (2^n)', labelEn: 'Map height (2^n)',
    docZh: '地图高度，以 2 的幂表示。', docEn: 'Map height as power of two.',
  ),
  // [difficulty]
  CatalogEntry(
    section: 'difficulty', key: 'max_no_competitors', type: CatalogType.int_,
    min: 0, max: 14,
    labelZh: 'AI 对手数量', labelEn: 'AI competitors',
    docZh: '0-14 个电脑对手。', docEn: 'Number of AI companies (0-14).',
  ),
  CatalogEntry(
    section: 'difficulty', key: 'max_competitors', type: CatalogType.int_,
    min: 0, max: 15,
    labelZh: '公司数量上限', labelEn: 'Max companies',
    docZh: '服务器/游戏内公司数量上限。', docEn: 'Maximum number of companies.',
  ),
  // [vehicle]
  CatalogEntry(
    section: 'vehicle', key: 'max_trains', type: CatalogType.int_,
    min: 0, max: 5000,
    labelZh: '火车上限', labelEn: 'Max trains',
    docZh: '每公司火车数量上限。', docEn: 'Per-company train limit.',
  ),
  CatalogEntry(
    section: 'vehicle', key: 'max_roadveh', type: CatalogType.int_,
    min: 0, max: 5000,
    labelZh: '公路车辆上限', labelEn: 'Max road vehicles',
    docZh: '每公司公路车辆上限。', docEn: 'Per-company road vehicle limit.',
  ),
  CatalogEntry(
    section: 'vehicle', key: 'max_aircraft', type: CatalogType.int_,
    min: 0, max: 5000,
    labelZh: '飞机上限', labelEn: 'Max aircraft',
    docZh: '每公司飞机数量上限。', docEn: 'Per-company aircraft limit.',
  ),
  CatalogEntry(
    section: 'vehicle', key: 'max_ships', type: CatalogType.int_,
    min: 0, max: 5000,
    labelZh: '轮船上限', labelEn: 'Max ships',
    docZh: '每公司轮船数量上限。', docEn: 'Per-company ship limit.',
  ),
  // [network]
  CatalogEntry(
    section: 'network', key: 'client_name', type: CatalogType.string,
    labelZh: '联机昵称', labelEn: 'Client name',
    docZh: '联机时显示的玩家名称。', docEn: 'Player name shown in multiplayer.',
  ),
  CatalogEntry(
    section: 'network', key: 'server_name', type: CatalogType.string,
    labelZh: '服务器名称', labelEn: 'Server name',
    docZh: '做主机时显示的服务器名称。', docEn: 'Server name when hosting.',
  ),
  CatalogEntry(
    section: 'network', key: 'server_port', type: CatalogType.int_,
    min: 1, max: 65535,
    labelZh: '服务器端口', labelEn: 'Server port',
    docZh: '做主机时监听的端口（默认 3979）。', docEn: 'Port to listen on when hosting (default 3979).',
  ),
];
