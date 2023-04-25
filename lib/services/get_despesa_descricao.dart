import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//pega descrição das despesas no firebase
class GetDespesaDescricao extends StatelessWidget {
  final String documentId;

  const GetDespesaDescricao({super.key, required this.documentId});

  Future<String?> getDespesaDescricao() async {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference despesas = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('despesas');

    DocumentSnapshot snapshot = await despesas.doc(documentId).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return data['descricao'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getDespesaDescricao(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Text('${snapshot.data ?? ''}');
        }
        return Text('Carregando...');
      },
    );
  }
}
