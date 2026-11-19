enum AppLanguage {
  vi,
  en,
}

class AppStrings {
  const AppStrings(this.lang);

  final AppLanguage lang;

  bool get isVi => lang == AppLanguage.vi;

  // Screen 1: Theme Hub
  String get appTitleLine1 => isVi ? 'BÉ TẬP' : 'KIDS';
  String get appTitleLine2 => isVi ? 'TÔ MÀU!' : 'COLORING!';
  String get appTitle => isVi ? 'Bé Tập Tô Màu!' : 'Kids Coloring!';
  String get chooseThemeSign => isVi ? 'CHỌN CHỦ ĐỀ!' : 'CHOOSE THEME!';
  String get unlockAll => isVi ? 'MỞ KHÓA TẤT CẢ' : 'UNLOCK ALL';
  String get vipUnlockedBadge => isVi ? 'ĐÃ MỞ VIP!' : 'VIP UNLOCKED!';

  // Screen 2: Drawing Select
  String get backButton => isVi ? 'QUAY LẠI' : 'BACK';
  String get playNowBig => isVi ? 'CHƠI NGAY' : 'PLAY NOW';
  String get lockedShort => isVi ? 'Khóa' : 'Lock';
  String get pagesCountSuffix => isVi ? 'tranh' : 'pics';

  // Common & Audio
  String get soundOn => isVi ? 'Bật âm thanh' : 'Sound On';
  String get soundOff => isVi ? 'Tắt âm thanh' : 'Muted';
  String get languageTooltip =>
      isVi ? 'Đổi sang Tiếng Anh' : 'Switch to Vietnamese';
  String get worlds => isVi ? 'Chủ đề' : 'Themes';
  String get home => isVi ? 'Trang chủ' : 'Home';
  String get back => isVi ? 'Quay lại' : 'Back';

  // Coloring Studio
  String get tapFill => isVi ? 'Đổ màu' : 'Fill';
  String get brushMode => isVi ? 'Cọ vẽ' : 'Brush';
  String get undo => isVi ? 'Hoàn tác' : 'Undo';
  String get redo => isVi ? 'Làm lại' : 'Redo';
  String get clear => isVi ? 'Xóa hết' : 'Clear';
  String get colorsTab => isVi ? '24 Màu' : 'Colors';
  String get magicTab => isVi ? 'Cọ Phép' : 'Magic';
  String get stickerTab => isVi ? 'Sticker' : 'Stickers';
  String get colorsAndBrushTab => isVi ? 'Màu & Cọ' : 'Colors';
  String get specialBrushesTitle => isVi ? 'Cọ Phép Thuật' : 'Magic Brushes';
  String get crayonsTitle => isVi ? 'Hộp 24 Bút Sáp' : '24 Crayon Box';
  String get stickerHint => isVi
      ? 'Chạm vào tranh để dán & kéo thả!'
      : 'Tap canvas to stick & drag around!';

  String get brushSolid => isVi ? 'Bút sáp' : 'Crayon';
  String get brushGlitter => isVi ? 'Kim tuyến' : 'Glitter';
  String get brushPolka => isVi ? 'Chấm bi' : 'Dots';
  String get brushRainbow => isVi ? 'Cầu vồng' : 'Rainbow';
  String get brushEraser => isVi ? 'Tẩy' : 'Eraser';

  String get celebrationMessage => isVi
      ? 'Hoan hô! Bé tô xong 100% rồi!'
      : 'Yay! Awesome job, 100% done!';

  String get emptyThemeMessage => isVi
      ? 'Chưa có tranh nào trong chủ đề này.\nHãy thả file .svg vào assets/svgs/!'
      : 'No pictures in this theme yet.\nDrop .svg files into assets/svgs/!';

  String loadError(Object err) =>
      isVi ? 'Không thể tải tranh: $err' : 'Could not load picture: $err';

  // Unlock & IAP
  String unlockPageTitle(String name) =>
      isVi ? 'Mở khóa "$name"' : 'Unlock "$name"';
  String get unlockPageBody => isVi
      ? 'Tranh đặc biệt này có thể mở miễn phí qua video thưởng hoặc mở toàn bộ với Gói VIP!'
      : 'Unlock this special picture for free with a rewarded video, or unlock everything with VIP!';
  String get watchRewardedAd =>
      isVi ? 'Xem Video Thưởng (Miễn phí)' : 'Watch Free Video';
  String get loading => isVi ? 'Đang mở...' : 'Loading...';
  String get unlockAllVipParents =>
      isVi ? 'Mở Toàn Bộ VIP (Phụ huynh)' : 'Unlock All VIP (Parents)';
  String get maybeLater => isVi ? 'Để sau' : 'Later';

  // Parental Gate
  String get parentalGateTitle => isVi ? 'Khu Vực Phụ Huynh' : 'Parents Only';
  String get parentalShopTitle =>
      isVi ? 'Cửa Hàng Phụ Huynh (VIP)' : 'Parent Shop (VIP)';
  String get parentalGateHint => isVi
      ? 'Phụ huynh hãy nhấn giữ nút tròn bên dưới trong 2.5 giây để tiếp tục.'
      : 'Grown-ups: press and hold the button below for 2.5 seconds.';
  String get holdLabel => isVi ? 'GIỮ 2.5s' : 'HOLD 2.5s';
  String get close => isVi ? 'Đóng lại' : 'Close';

  // Mock Shop
  String get vipProductTitle =>
      isVi ? 'Gói VIP Toàn Bộ Tranh' : 'VIP All-Access Pack';
  String get vipProductDesc => isVi
      ? 'Mở khóa toàn bộ tranh cao cấp, cọ đặc biệt & tắt quảng cáo.'
      : 'Unlock all premium pictures, magic brushes & remove ads.';
  String get removeAdsTitle => isVi ? 'Gỡ Quảng Cáo' : 'Remove Ads';
  String get removeAdsDesc => isVi
      ? 'Trải nghiệm tô màu an toàn, không quảng cáo cho bé.'
      : 'Enjoy a clean, ad-free coloring playground.';
  String get owned => isVi ? 'Đã sở hữu' : 'Owned';
  String get restorePurchases =>
      isVi ? 'Khôi phục giao dịch đã mua' : 'Restore Purchases';

  // Safe Banner Ad
  String get safeAdText => isVi
      ? 'Quảng cáo an toàn cho bé (AdMob Test)'
      : 'Kid-Safe Ad Space (AdMob Test)';
}
