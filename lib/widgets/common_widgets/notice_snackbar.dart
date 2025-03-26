import 'package:flutter/material.dart';

SnackBar noticeSnackbar(String message, bool isError) {
  return SnackBar(
    content: !isError
        ? Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Icon(
                    Icons.done_outline,
                    color: Colors.white,
                  )),
              Expanded(
                  flex: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Success",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      Text(message),
                    ],
                  )),
            ],
          )
        : Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                  )),
              Expanded(
                  flex: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Error",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      Text(message),
                    ],
                  )),
            ],
          ),
    backgroundColor: isError ? Colors.red : Colors.green,
    duration: Duration(seconds: 3), // Thời gian hiển thị
    action: SnackBarAction(
      label: 'Close',
      textColor: Colors.white,
      onPressed: () {
        // Đóng SnackBar khi nhấn
      },
    ),
    behavior: SnackBarBehavior.floating, // Hiển thị dạng nổi
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // Bo góc
    ),
    margin: EdgeInsets.all(10),
  );
}
