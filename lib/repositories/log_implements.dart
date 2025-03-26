import 'package:logger/logger.dart';

import 'log.dart';

class LogImplement implements Log {
  final Logger _logger = Logger();

  @override
  void i(String tag, String content) => _logger.i('$tag: $content');
  @override
  void d(String tag, String content) => _logger.d('$tag: $content');
  @override
  void e(String tag, String content) => _logger.e('$tag: $content');
}