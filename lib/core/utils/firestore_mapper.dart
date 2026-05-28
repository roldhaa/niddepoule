import 'package:cloud_firestore/cloud_firestore.dart';

/// Helpers pour mapper Firestore <-> modeles Dart.
class FirestoreMapper {
  static DateTime dateFromDynamic(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static Timestamp timestampFromDate(DateTime value) => Timestamp.fromDate(value);

  static Timestamp? timestampFromNullableDate(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }

  static double doubleFromDynamic(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return fallback;
  }

  static int intFromDynamic(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return fallback;
  }

  static List<String> stringListFromDynamic(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
  }
}
