import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class CloudNote{
  final String documentID;
  final String ownerUserID;
  final String text;
  const CloudNote({
    required this.documentID,
    required this.ownerUserID,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
      documentID = snapshot.id,
      ownerUserID = snapshot.data()[ownerUserIdFieldName],
      text = snapshot.data()[textFieldName] as String;
}


const ownerUserIdFieldName = 'user_id';
const textFieldName = 'text';