import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Upload des medias vers Firebase Storage.
class StorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;

  Future<String> uploadReportPhoto({
    required File file,
    required String userId,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('report_photos/$userId/$fileName');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadProfilePhoto({
    required File file,
    required String userId,
  }) async {
    final ref = _storage.ref().child('profile_photos/$userId/profile.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> deleteFileByUrl(String url) async {
    final ref = _storage.refFromURL(url);
    await ref.delete();
  }
}
