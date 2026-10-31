// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get aboutFlauncher => 'Giới thiệu Arc Launcher';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get addSection => 'Thêm mục';

  @override
  String get alphabetical => 'Theo bảng chữ cái';

  @override
  String get appCardHighlightAnimation => 'Hiệu ứng làm nổi bật ô ứng dụng';

  @override
  String get showFocusBorders => 'Hiện viền ô đang chọn';

  @override
  String get focusBorderThickness => 'Độ dày viền ô đang chọn';

  @override
  String get focusBorderThin => 'Mảnh (1,0 dp)';

  @override
  String get focusBorderDefault => 'Mặc định (1,5 dp)';

  @override
  String get focusBorderMedium => 'Vừa (2,0 dp)';

  @override
  String get focusBorderBold => 'Dày (3,0 dp)';

  @override
  String get appInfo => 'Thông tin ứng dụng';

  @override
  String get appKeyClick => 'Âm thanh khi bấm phím';

  @override
  String get appearanceSettings => 'Hiển thị';

  @override
  String get backgroundBlur => 'Làm mờ hình nền';

  @override
  String get dockBlur => 'Làm mờ thanh yêu thích';

  @override
  String get dockDarkBackground => 'Nền tối cho thanh yêu thích';

  @override
  String get dockShadow => 'Đổ bóng thanh yêu thích';

  @override
  String get applications => 'Ứng dụng';

  @override
  String get autoHideAppBar => 'Tự động ẩn thanh trạng thái';

  @override
  String get hideStatusBarInGrid => 'Ẩn thanh trạng thái khi xem lưới ứng dụng';

  @override
  String get backButtonAction => 'Chức năng nút Quay lại';

  @override
  String get category => 'Danh mục';

  @override
  String get categories => 'Danh mục';

  @override
  String get columnCount => 'Số cột';

  @override
  String get date => 'Ngày';

  @override
  String get dateAndTimeFormat => 'Định dạng ngày và giờ';

  @override
  String get delete => 'Xóa';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Không làm gì';

  @override
  String get dialogOptionBackButtonActionShowScreensaver =>
      'Mở trình bảo vệ màn hình';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Hiện đồng hồ';

  @override
  String get dialogTextNoFileExplorer =>
      'Vui lòng cài ứng dụng quản lý tệp để chọn ảnh.';

  @override
  String get dialogTitleBackButtonAction => 'Chọn chức năng cho nút Quay lại';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (Danh mục)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Ngày theo định dạng: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Giờ theo định dạng: $timeString';
  }

  @override
  String get gradient => 'Màu chuyển sắc';

  @override
  String get favoriteApps => 'Ứng dụng yêu thích';

  @override
  String get grid => 'Lưới';

  @override
  String get height => 'Chiều cao';

  @override
  String get hide => 'Ẩn';

  @override
  String get hiddenApplications => 'Ứng dụng đã ẩn';

  @override
  String get launcherSections => 'Các mục trên màn hình chính';

  @override
  String get layout => 'Bố cục';

  @override
  String get loading => 'Đang tải';

  @override
  String get manual => 'Thủ công';

  @override
  String get modifySection => 'Chỉnh sửa mục';

  @override
  String get mustNotBeEmpty => 'Không được để trống';

  @override
  String get name => 'Tên';

  @override
  String get newSection => 'Mục mới';

  @override
  String get noDateFormatSpecified => 'Chưa chọn định dạng ngày';

  @override
  String get noTimeFormatSpecified => 'Chưa chọn định dạng giờ';

  @override
  String get allApplications => 'Tất cả ứng dụng';

  @override
  String get nonTvApplications => 'Ứng dụng không dành cho TV';

  @override
  String get open => 'Mở';

  @override
  String get orSelectFormatSpecifiers => 'Hoặc chọn các thành phần định dạng';

  @override
  String get picture => 'Ảnh';

  @override
  String removeFrom(String name) {
    return 'Xóa khỏi $name';
  }

  @override
  String get renameCategory => 'Đổi tên danh mục';

  @override
  String get reorder => 'Sắp xếp lại';

  @override
  String get row => 'Hàng';

  @override
  String get rowHeight => 'Chiều cao hàng';

  @override
  String get save => 'Lưu';

  @override
  String get spacer => 'Khoảng trống';

  @override
  String get spacerMaxHeightRequirement =>
      'Phải lớn hơn 0 và không vượt quá 500';

  @override
  String get statusBar => 'Thanh trạng thái';

  @override
  String get settings => 'Cài đặt';

  @override
  String get show => 'Hiện';

  @override
  String get showCategoryTitles => 'Hiện tên danh mục';

  @override
  String get sort => 'Sắp xếp';

  @override
  String get systemSettings => 'Cài đặt hệ thống';

  @override
  String get updateCheck => 'Kiểm tra cập nhật';

  @override
  String get updateNoUpdateTitle => 'Chưa có bản cập nhật';

  @override
  String updateNoUpdateBody(String currentVersion) {
    return 'Bạn đang dùng phiên bản mới nhất ($currentVersion).';
  }

  @override
  String get updateAvailableTitle => 'Có bản cập nhật';

  @override
  String updateAvailableBody(String latestVersion, String currentVersion) {
    return 'Đã có phiên bản $latestVersion (hiện tại: $currentVersion).';
  }

  @override
  String get updateChangelog => 'Có gì mới';

  @override
  String get updateDownloadButton => 'Tải xuống';

  @override
  String get updateReadyToInstallTitle => 'Sẵn sàng cài đặt';

  @override
  String updateReadyToInstallBody(String latestVersion) {
    return 'Đã tải APK phiên bản $latestVersion. Bạn muốn cài đặt ngay không?';
  }

  @override
  String get updateInstallButton => 'Cài đặt';

  @override
  String get updateInstallPermissionTitle => 'Cần quyền cài đặt ứng dụng';

  @override
  String get updateInstallPermissionBody =>
      'Cho phép Arc Launcher cài ứng dụng không rõ nguồn gốc, rồi thử cập nhật lại.';

  @override
  String get updateOpenPermissionSettingsButton => 'Mở cài đặt quyền';

  @override
  String get updateErrorGeneric =>
      'Không thể kiểm tra cập nhật. Vui lòng thử lại.';

  @override
  String textAboutDialog(String repoUrl) {
    return 'Arc Launcher là ứng dụng màn hình chính mã nguồn mở dành cho Android TV, được tùy chỉnh từ FLauncher.\n\nDo Meddouri Badis phát triển.\nMã nguồn tại $repoUrl.';
  }

  @override
  String get textEmptyCategory => 'Danh mục này đang trống.';

  @override
  String get time => 'Giờ';

  @override
  String get titleStatusBarSettingsPage =>
      'Chọn nội dung hiển thị trên thanh trạng thái';

  @override
  String get tvApplications => 'Ứng dụng dành cho TV';

  @override
  String get type => 'Loại';

  @override
  String get typeInTheDateFormat => 'Nhập định dạng ngày';

  @override
  String get typeInTheHourFormat => 'Nhập định dạng giờ';

  @override
  String get uninstall => 'Gỡ cài đặt';

  @override
  String get wallpaper => 'Hình nền';

  @override
  String get withEllipsisAddTo => 'Thêm vào...';

  @override
  String get timeBasedWallpaper => 'Đổi hình nền theo thời gian';

  @override
  String get unsplashSlideshow => 'Trình chiếu ảnh Unsplash';

  @override
  String get unsplashEnable => 'Hiện ảnh từ Unsplash';

  @override
  String get unsplashAccessKey => 'Khóa truy cập Unsplash';

  @override
  String get unsplashAccessKeyHelp =>
      'Tạo ứng dụng miễn phí tại unsplash.com/developers rồi dán khóa truy cập (Access Key) vào đây.';

  @override
  String get unsplashNotSet => 'Chưa thiết lập';

  @override
  String get unsplashInterval => 'Đổi ảnh sau mỗi';

  @override
  String unsplashIntervalMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String get slideshowCategories => 'Chủ đề';

  @override
  String get slideshowDay => 'Ban ngày (6:00–18:00)';

  @override
  String get slideshowNight => 'Ban đêm (18:00–6:00)';

  @override
  String unsplashPhotoCredit(String author) {
    return 'Ảnh: $author / Unsplash';
  }

  @override
  String get pickDayWallpaper => 'Chọn hình nền ban ngày';

  @override
  String get pickNightWallpaper => 'Chọn hình nền ban đêm';

  @override
  String get video => 'Video';

  @override
  String get pickDayVideoWallpaper => 'Chọn video nền ban ngày';

  @override
  String get pickNightVideoWallpaper => 'Chọn video nền ban đêm';

  @override
  String get watchNextSectionTitle => 'Xem tiếp';

  @override
  String get showWatchNextSection => 'Hiện mục Xem tiếp';

  @override
  String get watchNextPermissionTitle => 'Cần cấp quyền cho mục Xem tiếp';

  @override
  String get watchNextPermissionBody =>
      'Cho phép truy cập danh sách chương trình TV để hiện những nội dung bạn đang xem dở.';

  @override
  String get watchNextGrantPermission => 'Cấp quyền';

  @override
  String get watchNextCheckPermission => 'Kiểm tra lại';

  @override
  String get interface => 'Giao diện';

  @override
  String get system => 'Hệ thống';

  @override
  String get accentColor => 'Màu nhấn';

  @override
  String get miscellaneous => 'Tùy chọn khác';

  @override
  String get brightnessScheduler => 'Lịch điều chỉnh độ sáng';

  @override
  String get screensaverSettings => 'Cài đặt trình bảo vệ màn hình';

  @override
  String get screensaverClockStyle => 'Kiểu đồng hồ bảo vệ màn hình';

  @override
  String get wifiUsagePeriod => 'Chu kỳ thống kê Wi-Fi';

  @override
  String get showAppNamesBelowIcons => 'Hiện tên ứng dụng dưới biểu tượng';

  @override
  String get wifiUsage => 'Dung lượng Wi-Fi đã dùng';

  @override
  String get networkIndicator => 'Trạng thái mạng';

  @override
  String get customName => 'Tên tùy chỉnh';

  @override
  String get lastUsed => 'Dùng gần đây';

  @override
  String get daily => 'Hằng ngày';

  @override
  String get weekly => 'Hằng tuần';

  @override
  String get monthly => 'Hằng tháng';

  @override
  String get grantPermission => 'Cấp quyền';

  @override
  String get checkStatus => 'Kiểm tra trạng thái';

  @override
  String get watchNextBigPictureMode => 'Chế độ chìm đắm';

  @override
  String get watchNextBigPictureModeDescription =>
      'Hiển thị hình nền nổi bật toàn màn hình với nút xem tác vụ';

  @override
  String get watchNextWatch => 'Xem';

  @override
  String get watchNextResume => 'Tiếp tục xem';

  @override
  String get watchNextRefresh => 'Làm mới nội dung';

  @override
  String get watchNextRefreshDescription =>
      'Tải lại đề xuất từ các ứng dụng đa phương tiện';

  @override
  String get watchNextRefreshed => 'Đã làm mới nội dung Tiếp tục xem';

  @override
  String get watchNextFilterApps => 'Lọc ứng dụng';

  @override
  String get watchNextFilterAppsDescription =>
      'Chọn ứng dụng có thể hiển thị nội dung trong Tiếp tục xem';

  @override
  String get watchNextNoApps =>
      'Hiện không có ứng dụng truyền thông nào cung cấp nội dung Tiếp tục xem';

  @override
  String get watchNextShowAllApps => 'Hiển thị tất cả ứng dụng đã cài đặt';

  @override
  String get watchNextHideWithoutImages => 'Ẩn chương trình không có hình ảnh';

  @override
  String get watchNextHideWithoutImagesDescription =>
      'Chỉ hiển thị các chương trình có hình ảnh áp phích hoặc hình nền';

  @override
  String get watchNextMaxItems => 'Số lượng chương trình tối đa';

  @override
  String get watchNextMaxItemsDescription =>
      'Giới hạn số lượng chương trình hiển thị trong Tiếp tục xem';

  @override
  String get watchNextMaxItemsUnlimited => 'Không giới hạn';

  @override
  String get redditWallpaper => 'Hình nền Reddit';

  @override
  String get redditWallpaperEnable => 'Hiện hình nền từ Reddit';

  @override
  String get redditSubreddits => 'Cộng đồng Reddit';

  @override
  String get redditSort => 'Sắp xếp theo';

  @override
  String get redditSortHot => 'Nổi bật';

  @override
  String get redditSortTopDay => 'Hàng đầu hôm nay';

  @override
  String get redditSortTopWeek => 'Hàng đầu tuần này';

  @override
  String get redditSortTopMonth => 'Hàng đầu tháng này';

  @override
  String get redditSortTopAll => 'Hàng đầu từ trước đến nay';

  @override
  String get redditSortNew => 'Mới nhất';

  @override
  String get redditInterval => 'Đổi ảnh sau mỗi';

  @override
  String redditIntervalMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String get redditInterval1Hour => '1 giờ';

  @override
  String redditIntervalHours(int hours) {
    return '$hours giờ';
  }

  @override
  String get redditInterval1Day => '1 ngày';

  @override
  String redditIntervalDays(int days) {
    return '$days ngày';
  }

  @override
  String get redditClientId => 'Mã ứng dụng Reddit (không bắt buộc)';

  @override
  String get redditClientIdHelp =>
      'Không bắt buộc. Nếu mạng của bạn yêu cầu, hãy tạo ứng dụng loại installed app tại reddit.com/prefs/apps rồi dán mã ứng dụng vào đây.';

  @override
  String get redditChangeNow => 'Đổi hình nền ngay';

  @override
  String get redditAddSubreddit => 'Thêm cộng đồng Reddit';

  @override
  String get redditSubredditName => 'Tên cộng đồng (không có r/)';

  @override
  String get redditSubredditAdded => 'Đã thêm cộng đồng Reddit';

  @override
  String get redditSubredditInvalid =>
      'Vui lòng nhập tên cộng đồng Reddit hợp lệ';

  @override
  String get redditWallpaperUpdated => 'Đã đổi hình nền';

  @override
  String get redditWallpaperFailed =>
      'Không thể tải hình nền. Nếu lỗi tiếp diễn, hãy thiết lập mã ứng dụng Reddit trong phần cài đặt.';

  @override
  String get addToFavorites => 'Thêm vào yêu thích';

  @override
  String get removeFromFavorites => 'Bỏ khỏi yêu thích';

  @override
  String get addToCategory => 'Thêm vào danh mục';

  @override
  String get setCustomBanner => 'Đặt ảnh đại diện tùy chỉnh';

  @override
  String get clearCustomBanner => 'Xóa ảnh đại diện tùy chỉnh';

  @override
  String customBannerSetFailed(String error) {
    return 'Không thể đặt ảnh đại diện: $error';
  }

  @override
  String customBannerClearFailed(String error) {
    return 'Không thể xóa ảnh đại diện: $error';
  }

  @override
  String get selectImage => 'Chọn ảnh';

  @override
  String get selectVideo => 'Chọn video';

  @override
  String mediaItemCount(int count) {
    return '$count mục';
  }

  @override
  String get noImagesFound => 'Không tìm thấy ảnh trên thiết bị';

  @override
  String get noVideosFound => 'Không tìm thấy video trên thiết bị';

  @override
  String get mediaNavigationHint =>
      'Phím điều hướng: di chuyển  •  Quay lại: hủy';

  @override
  String get mediaSelectionHint =>
      'Phím điều hướng: di chuyển  •  OK: đặt hình nền  •  Quay lại: hủy';

  @override
  String get mediaPermissionRequired => 'Cần quyền truy cập ảnh và video';

  @override
  String get mediaPermissionHelp => 'Cấp quyền để duyệt ảnh và video';

  @override
  String get preview => 'Xem trước';

  @override
  String get colorPurple => 'Tím';

  @override
  String get colorTeal => 'Xanh cổ vịt';

  @override
  String get colorBlue => 'Xanh dương';

  @override
  String get colorOrange => 'Cam';

  @override
  String get colorPink => 'Hồng';

  @override
  String get colorGreen => 'Xanh lá';

  @override
  String get colorWhite => 'Trắng';

  @override
  String get colorYellow => 'Vàng';

  @override
  String get colorRed => 'Đỏ';

  @override
  String get colorCyan => 'Xanh lơ';

  @override
  String get colorIndigo => 'Chàm';

  @override
  String get colorLime => 'Xanh nõn chuối';

  @override
  String get colorAmber => 'Hổ phách';

  @override
  String get colorRose => 'Hồng phấn';

  @override
  String get colorIceBlue => 'Xanh băng';

  @override
  String get clockStyleMinimal => 'Tối giản';

  @override
  String get clockStyleMinimalDescription => 'Chữ mảnh, thanh lịch (mặc định)';

  @override
  String get clockStyleBold => 'Chữ đậm';

  @override
  String get clockStyleBoldDescription => 'Chữ dày, dễ nhìn';

  @override
  String get clockStyleRetro => 'Hoài cổ';

  @override
  String get clockStyleRetroDescription =>
      'Chữ đơn cách, kiểu màn hình máy tính cổ';

  @override
  String get clockStyleElegant => 'Thanh lịch';

  @override
  String get clockStyleElegantDescription => 'Kiểu chữ có chân cổ điển';

  @override
  String get clockStyleNeon => 'Neon';

  @override
  String get clockStyleNeonDescription =>
      'Chữ siêu mảnh với hiệu ứng phát sáng';

  @override
  String get clockStylePixel => 'Điểm ảnh';

  @override
  String get clockStylePixelDescription =>
      'Chữ đơn cách đậm, phong cách trò chơi cổ';

  @override
  String get clockStyleDigital => 'Kỹ thuật số';

  @override
  String get clockStyleDigitalDescription => 'Chữ đơn cách rõ ràng';

  @override
  String get brightnessPermissionRequired => 'Cần cấp quyền';

  @override
  String get brightnessPermissionHelp =>
      'Để điều chỉnh độ sáng trên thiết bị này, bạn cần cấp quyền qua ADB:';

  @override
  String get brightnessExperimentalNotice =>
      'THỬ NGHIỆM: Tính năng này chưa được kiểm chứng và có thể bị loại bỏ trong các phiên bản sau tùy theo phản hồi của người dùng.';

  @override
  String get brightnessDeviceSupportNote =>
      'Lưu ý: Một số thiết bị Android TV có thể không hỗ trợ điều chỉnh độ sáng từ ứng dụng.';

  @override
  String get enableBrightnessScheduler => 'Bật lịch điều chỉnh độ sáng';

  @override
  String currentBrightnessSlot(String slot) {
    return 'Hiện tại: $slot';
  }

  @override
  String get brightnessSlotMorning => '6:00–9:00';

  @override
  String get brightnessSlotDay => '9:00–15:00';

  @override
  String get brightnessSlotAfternoon => '15:00–18:00';

  @override
  String get brightnessSlotEvening => '18:00–22:00';

  @override
  String get brightnessSlotNight => '22:00–6:00';

  @override
  String get showWallpaperCredits => 'Hiển thị nguồn hình nền';

  @override
  String get panels => 'Bảng tiện ích';

  @override
  String get showDailyAyah => 'Hiển thị câu Kinh Qur’an trong ngày';

  @override
  String get calendar => 'Calendar';

  @override
  String get calendarShow => 'Show calendar on Home';

  @override
  String get calendarUrl => 'iCal URL';

  @override
  String get calendarNotConfigured => 'No calendar connected';

  @override
  String get calendarConfigured => 'Calendar URL saved';

  @override
  String get calendarRefresh => 'Refresh now';

  @override
  String get calendarLoading => 'Loading calendar…';

  @override
  String get calendarLoadFailed =>
      'Could not refresh. Check the iCal URL and your connection.';

  @override
  String get calendarUpdated => 'Calendar is up to date';

  @override
  String get calendarCached => 'Last saved calendar';

  @override
  String get calendarRemove => 'Disconnect calendar';

  @override
  String get calendarUntitled => 'Untitled event';

  @override
  String get calendarInvalidUrl => 'Enter a valid HTTPS iCal URL.';

  @override
  String get calendarHelp =>
      'Shows the next seven days on Home without taking remote focus. Refreshes every 15 minutes. Use Google Calendar’s secret iCal address and keep it private.';

  @override
  String get calendarCancel => 'Cancel';

  @override
  String get calendarDayEmpty => 'No events';

  @override
  String get calendarContinues => 'Continues';

  @override
  String get wallhavenWallpaper => 'Hình nền Wallhaven';

  @override
  String get wallhavenEnable => 'Hiển thị hình nền Wallhaven';

  @override
  String get wallhavenSearchTerms => 'Từ khóa tìm kiếm';

  @override
  String get wallhavenSearchTermsHelp =>
      'Ngăn cách các từ khóa bằng dấu phẩy, ví dụ: nature, mountains, ocean. Mỗi lần đổi hình nền sẽ chọn ngẫu nhiên một từ khóa, rồi chọn một hình nền ngang ngẫu nhiên.';

  @override
  String get wallhavenNextWallpaper => 'Hình nền tiếp theo';

  @override
  String get wallhavenWallpaperFailed =>
      'Không tìm thấy hình nền. Hãy kiểm tra từ khóa tìm kiếm và kết nối.';

  @override
  String get wallhavenAttribution =>
      'Hình nền từ Wallhaven · https://wallhaven.cc';

  @override
  String get gistWallpaper => 'Hình nền từ Gist';

  @override
  String get gistWallpaperEnable => 'Sử dụng hình nền từ Gist';

  @override
  String get gistWallpaperHelp =>
      'Mỗi dòng chứa một URL HTTPS trực tiếp tới hình ảnh hoặc video. Các dòng trống và dòng bắt đầu bằng # sẽ bị bỏ qua. Làm mới để tải lại danh sách; Hình nền tiếp theo chọn ngẫu nhiên một mục. Các tệp tải xuống được lưu để phát khi ngoại tuyến.';

  @override
  String get gistWallpaperFailed =>
      'Không thể tải hình nền. Hãy kiểm tra URL nguồn và URL ảnh hoặc video.';

  @override
  String get feedRefresh => 'Làm mới nội dung';

  @override
  String get feedRefreshed => 'Đã làm mới nội dung';

  @override
  String get feedRefreshFailed =>
      'Làm mới thất bại. Tiếp tục sử dụng nội dung gần nhất hoạt động.';

  @override
  String get refreshAyahs => 'Làm mới các câu Kinh Qur’an';
}
