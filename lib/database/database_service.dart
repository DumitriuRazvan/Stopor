import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/models/user.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService _instance =
      DatabaseService._privateConstructor();
  factory DatabaseService() {
    return _instance;
  }

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> uploadPic(image) async {
    Reference ref = storage.ref().child("image" + DateTime.now().toString());
    TaskSnapshot uploadTask = await ref.putFile(File(image));
    return uploadTask.ref.getDownloadURL();
  }

  Future<void> uploadEvent(event) async {
    firestore.collection('events').add(event.toJSON());
  }

  Future getEventList(pageKey, pageSize) async {
    try {
      var events;
      print(pageKey);
      if (pageKey != "") {
        var docRef = firestore.collection('events').doc(pageKey);
        var snapshot = await docRef.get();
        events = await firestore
            .collection('events')
            .startAfterDocument(snapshot)
            .limit(pageSize)
            .get();
      } else {
        events = await firestore.collection('events').limit(pageSize).get();
      }
      var data = events.docs;
      List<Event> eventObjects = [];
      data.forEach((element) {
        Event event = new Event(
            id: element.id,
            description: element.data()["description"],
            date: DateTime(2020, 9, 17, 17, 30),
            name: element.data()["name"],
            eventImage: element.data()["image"] != false
                ? element.data()["image"]
                : "https://keysight-h.assetsadobe.com/is/image/content/dam/keysight/en/img/prd/ixia-homepage-redirect/network-visibility-and-network-test-products/Network-Test-Solutions-New.jpg",
            location: element.data()["location"],
            isOnline: element.data()["isOnline"] == null ? false : true,
            facebookId: element.data()["facebookId"]);
        eventObjects.add(event);
      });
      return eventObjects;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> setUserSpotifyToken(String uid, String spotifyAuthToken) async {
    firestore
        .collection('users')
        .doc(uid)
        .update({"spotifyAuthToken": spotifyAuthToken});
  }
}
