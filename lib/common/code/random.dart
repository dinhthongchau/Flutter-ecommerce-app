import 'dart:math';

int generateRandomId() {
  DateTime now = DateTime.now();

  // Lấy 6 số từ ngày tháng (yyMMdd)
  String datePart = now.year.toString().substring(2) +
      now.month.toString().padLeft(2, '0') +
      now.day.toString().padLeft(2, '0'); // yyMMdd

  // Tạo 3 số ngẫu nhiên
  String randomPart =
      Random().nextInt(900).toString().padLeft(3, '0'); // 3 chữ số random

  // Kết hợp lại thành số nguyên
  return int.parse(datePart + randomPart);
}
