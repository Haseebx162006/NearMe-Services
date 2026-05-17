/// Parses MongoDB ids from API JSON (string, ObjectId map, etc.).
String parseMongoId(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is Map) {
    final oid = value[r'$oid'] ?? value['oid'] ?? value['_id'];
    if (oid != null) return parseMongoId(oid);
  }
  final text = value.toString().trim();
  if (text.startsWith('Instance of')) return '';
  return text;
}

bool mongoIdsMatch(String a, String b) {
  final x = parseMongoId(a);
  final y = parseMongoId(b);
  if (x.isEmpty || y.isEmpty) return false;
  return x == y;
}
