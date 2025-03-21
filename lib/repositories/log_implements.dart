import 'log.dart';

class LogImplement implements Log {
  @override
  void d(String tag, String content) {
    print("$tag $content");
  }

  @override
  void e(String tag, String content) {
    print("$tag $content");
  }

  @override
  void i(String tag, String content) {
    print("$tag $content");
  }
}
