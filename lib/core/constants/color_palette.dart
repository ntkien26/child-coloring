import 'package:flutter/material.dart';

class PaletteColorItem {
  const PaletteColorItem({
    required this.name,
    required this.color,
    required this.group,
  });

  final String name;
  final Color color;
  final String group;
}

class AppColorPalette {
  AppColorPalette._();

  /// 24 bright, kid-friendly crayon colors organized into 4 clear groups.
  static const List<PaletteColorItem> colors = [
    // Nhóm 1: Đỏ - Cam - Vàng (6 màu)
    PaletteColorItem(name: 'Đỏ Tươi', color: Color(0xFFFF3B30), group: 'Nóng'),
    PaletteColorItem(name: 'Đỏ Dâu', color: Color(0xFFFF5C8A), group: 'Nóng'),
    PaletteColorItem(name: 'Cam Rực', color: Color(0xFFFF7A00), group: 'Nóng'),
    PaletteColorItem(name: 'Cam Đào', color: Color(0xFFFFA952), group: 'Nóng'),
    PaletteColorItem(name: 'Vàng Nắng', color: Color(0xFFFFD60A), group: 'Nóng'),
    PaletteColorItem(name: 'Vàng Kem', color: Color(0xFFFFF07C), group: 'Nóng'),

    // Nhóm 2: Xanh Lá - Ngọc Bích (6 màu)
    PaletteColorItem(name: 'Xanh Chanh', color: Color(0xFF9EF01A), group: 'Lá'),
    PaletteColorItem(name: 'Xanh Lá', color: Color(0xFF38B000), group: 'Lá'),
    PaletteColorItem(name: 'Xanh Rừng', color: Color(0xFF1B8A5A), group: 'Lá'),
    PaletteColorItem(name: 'Xanh Bạc Hà', color: Color(0xFF5CE1E6), group: 'Lá'),
    PaletteColorItem(name: 'Xanh Ngọc', color: Color(0xFF00B4D8), group: 'Lá'),
    PaletteColorItem(name: 'Xanh Biển', color: Color(0xFF0077B6), group: 'Lá'),

    // Nhóm 3: Xanh Dương - Tím - Hồng (6 màu)
    PaletteColorItem(name: 'Xanh Trời', color: Color(0xFF4CC9F0), group: 'Mát'),
    PaletteColorItem(name: 'Xanh Coban', color: Color(0xFF3A86FF), group: 'Mát'),
    PaletteColorItem(name: 'Chàm', color: Color(0xFF4361EE), group: 'Mát'),
    PaletteColorItem(name: 'Tím Mơ', color: Color(0xFF9B5DE5), group: 'Mát'),
    PaletteColorItem(name: 'Tím Oải Hương', color: Color(0xFFC77DFF), group: 'Mát'),
    PaletteColorItem(name: 'Hồng Kẹo', color: Color(0xFFFF85C0), group: 'Mát'),

    // Nhóm 4: Nâu - Da - Trung Tính (6 màu)
    PaletteColorItem(name: 'Màu Da', color: Color(0xFFFFD6BA), group: 'Tự nhiên'),
    PaletteColorItem(name: 'Nâu Mật', color: Color(0xFFD4A373), group: 'Tự nhiên'),
    PaletteColorItem(name: 'Nâu Gỗ', color: Color(0xFF9C6644), group: 'Tự nhiên'),
    PaletteColorItem(name: 'Xám Mây', color: Color(0xFFADB5BD), group: 'Tự nhiên'),
    PaletteColorItem(name: 'Than Chì', color: Color(0xFF343A40), group: 'Tự nhiên'),
    PaletteColorItem(name: 'Trắng Tuyết', color: Color(0xFFFFFFFF), group: 'Tự nhiên'),
  ];
}
