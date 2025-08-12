import 'dart:convert';

String extractMeta(String body, String property) {
  final re = RegExp('<meta[^>]+property=["\']\$property["\'][^>]+content=["\']([^"\']+)["\']', caseSensitive: false);
  final m = re.firstMatch(body);
  if (m != null) return m.group(1)!;
  final re2 = RegExp('<meta[^>]+name=["\']\$property["\'][^>]+content=["\']([^"\']+)["\']', caseSensitive: false);
  final m2 = re2.firstMatch(body);
  if (m2 != null) return m2.group(1)!;
  return '';
}

Map<String,dynamic> tryParseJsonLd(String body) {
  final re = RegExp(r'<script[^>]+type=["\']application/ld\+json["\'][^>]*>(.*?)<\/script>', dotAll: true, caseSensitive: false);
  final match = re.firstMatch(body);
  if (match != null) {
    final jsonText = match.group(1)!.trim();
    try {
      final parsed = json.decode(jsonText);
      if (parsed is Map) return Map<String,dynamic>.from(parsed);
      if (parsed is List && parsed.isNotEmpty && parsed[0] is Map) return Map<String,dynamic>.from(parsed[0]);
    } catch (e) {
      // ignore
    }
  }
  return {};
}
