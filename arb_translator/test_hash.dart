import 'package:crypto/crypto.dart';
import 'dart:convert';

void main() {
  print('Hello {name}: ${sha256.convert(utf8.encode('Hello {name}'))}');
  print('Welcome to our app: ${sha256.convert(utf8.encode('Welcome to our app'))}');
}
