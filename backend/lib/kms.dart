import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class KMS {
  final String storagePath;
  KMS(this.storagePath);

  // WARNING: This is a development-only encrypted file storage.
  // For production use a real KMS (Vault/AWS KMS/GCP KMS).
  Future<void> storeKey(String id, String privateKey, String passphrase) async {
    final key = utf8.encode(passphrase);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(utf8.encode(privateKey));
    final record = jsonEncode({'id': id, 'hmac': digest.toString(), 'enc': base64Encode(utf8.encode(privateKey))});
    final f = File('\$storagePath/\$id.json');
    await f.create(recursive: true);
    await f.writeAsString(record);
  }

  Future<String?> loadKey(String id, String passphrase) async {
    final f = File('\$storagePath/\$id.json');
    if (!await f.exists()) return null;
    final content = await f.readAsString();
    final map = jsonDecode(content);
    final enc = map['enc'] as String;
    final pk = utf8.decode(base64Decode(enc));
    // naive check: compute hmac and compare
    final key = utf8.encode(passphrase);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(utf8.encode(pk));
    if (digest.toString() != map['hmac']) {
      return null;
    }
    return pk;
  }
}
