import '../enum/screen_size.dart';

ScreenSize calculateScreenSize(double width) {
  if (width < 600) {
    return ScreenSize.small;
  } else if (width < 800) {
    return ScreenSize.medium;
  } else {
    return ScreenSize.large;
  }
}
