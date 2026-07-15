import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted SHA-256 password hashing. Each password gets its own random salt
/// so two employees with the same password don't produce the same hash,
/// and stored hashes can't be reversed or directly compared to look up
/// a password.
class PasswordHasher {
  PasswordHasher._();

  static String generateSalt({int length = 16}) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String password, String salt, String expectedHash) {
    return hash(password, salt) == expectedHash;
  }
}
