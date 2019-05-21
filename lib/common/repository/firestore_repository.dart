import 'package:arduino_drum_emulator/common/model/iteration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionProvider {
  Firestore _firestore = Firestore.instance;
  CollectionReference _collectionReference;

  SessionProvider() {
    _collectionReference = _firestore.collection('sessionInstrument');
  }

  Future<List<Iteration>> getIteration(String instrumentId) async {
    var documentSnapshot = await _collectionReference
        .where('instrumentId', isEqualTo: '3224')
        .getDocuments();
    var doc = documentSnapshot.documents.first;
    return Iteration.listFromDocuments(doc.data['iteration']);
  }

  Future<Duration> getTrackTime(String trackId) async {
    var documentSnapshot = await _collectionReference
        .where('instrumentId', isEqualTo: '3224')
        .getDocuments();
    var doc = documentSnapshot.documents.first;
    return Duration(seconds: doc.data['duration']);
  }

  Future<void> sendResponse(String status) async {
    var documentSnapshot = await _collectionReference
        .where('instrumentId', isEqualTo: '3224')
        .getDocuments();
    var doc = documentSnapshot.documents.first;
    await _collectionReference.document(doc.documentID).updateData(
      {
        'statusMap': {
          'status': status,
          'response': true,
        },
      },
    );
  }

  void clearSession(String instrument) async {
    var documentSnapshot = await _collectionReference
        .where('instrumentId', isEqualTo: '3224')
        .getDocuments();
    var doc = documentSnapshot.documents.first;
    _collectionReference.document(doc.documentID).delete();
  }

  Stream<QuerySnapshot> getSessionStream() {
    return _collectionReference.snapshots();
  }
}
