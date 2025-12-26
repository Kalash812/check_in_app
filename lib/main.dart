import 'package:check_in_app/bootstrap.dart';
import 'package:check_in_app/ui/app/app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const CheckInApp());
}
