import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  // ignore: avoid_print
  print('Hello {name}: ${sha256.convert(utf8.encode('Hello {name}'))}');
  // ignore: avoid_print
  print('Welcome to our app: ${sha256.convert(utf8.encode('Welcome to our app'))}');
}
