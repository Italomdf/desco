import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//pega tipo das despesas no firebase
class GetDespesaTipo extends StatelessWidget {
  final String documentId;
  const GetDespesaTipo({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference despesas = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('despesas');

    return FutureBuilder<DocumentSnapshot>(
      future: despesas.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Text('${data['tipo']}');
        }
        return Text('Carregando...');
      },
    );
  }
}
