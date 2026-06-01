import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

class OpenDataService {
  OpenDataService(this._firestore);

  final FirebaseFirestore _firestore;

  /// Fetches real potholes from Montréal's 311 Citizen Requests dataset
  /// and seeds them in Firestore in batches of 400.
  Future<int> ingestMontrealPotholes(int limit) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(
        'https://donnees.montreal.ca/api/3/action/datastore_search'
        '?resource_id=2cfa0e06-9be4-49a6-b7f1-ee9f2363a872'
        '&q=Nid-de-poule'
        '&limit=$limit',
      );

      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) {
        throw HttpException('Montreal CKAN API returned status code ${response.statusCode}');
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final json = jsonDecode(responseBody) as Map<String, dynamic>;

      if (json['success'] != true) {
        throw StateError('API request succeeded, but payload indicated failure.');
      }

      final result = json['result'] as Map<String, dynamic>?;
      if (result == null) return 0;

      final records = result['records'] as List<dynamic>?;
      if (records == null || records.isEmpty) return 0;

      final List<Map<String, dynamic>> parsedPotholes = [];
      final now = DateTime.now();

      for (final record in records) {
        final Map<String, dynamic> data = record as Map<String, dynamic>;

        final lat = double.tryParse(data['LOC_LAT']?.toString() ?? '') ?? 0.0;
        final lon = double.tryParse(data['LOC_LONG']?.toString() ?? '') ?? 0.0;

        // Skip records with invalid locations
        if (lat == 0.0 || lon == 0.0) continue;

        final uniqueId = data['ID_UNIQUE']?.toString() ?? 
            data['_id']?.toString() ?? 
            'opendata_${now.microsecondsSinceEpoch}_${parsedPotholes.length}';

        final rawDate = data['DDS_DATE_CREATION']?.toString() ?? '';
        final firstReported = DateTime.tryParse(rawDate) ?? now;

        final rawUpdate = data['DATE_DERNIER_STATUT']?.toString() ?? '';
        final lastReported = DateTime.tryParse(rawUpdate) ?? firstReported;

        final geohash = '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';

        // Distribute danger levels deterministically based on ID hash
        DangerLevel dangerLevel;
        final hashMod = uniqueId.hashCode % 10;
        if (hashMod < 2) {
          dangerLevel = DangerLevel.high;
        } else if (hashMod < 5) {
          dangerLevel = DangerLevel.low;
        } else {
          dangerLevel = DangerLevel.medium;
        }

        parsedPotholes.add({
          'id': uniqueId,
          'latitude': lat,
          'longitude': lon,
          'geohash': geohash,
          'dangerLevel': dangerLevel.name,
          'reportCount': (uniqueId.hashCode % 3) + 1,
          'status': 'open',
          'firstReportedAt': Timestamp.fromDate(firstReported),
          'lastReportedAt': Timestamp.fromDate(lastReported),
          'photoUrls': <String>[],
          'city': 'Montréal',
          'repairedAt': null,
        });
      }

      if (parsedPotholes.isEmpty) return 0;

      int count = 0;
      WriteBatch batch = _firestore.batch();

      for (int i = 0; i < parsedPotholes.length; i++) {
        final data = parsedPotholes[i];
        final id = data['id'] as String;
        final docRef = _firestore.collection('potholes').doc(id);

        batch.set(docRef, data);
        count++;

        // Commit and refresh batch if we hit 400 (to stay under Firestore's 500 batch limit)
        if (count % 400 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      if (count % 400 != 0) {
        await batch.commit();
      }

      return count;
    } finally {
      client.close();
    }
  }
}
