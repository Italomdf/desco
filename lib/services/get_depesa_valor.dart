import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//pega valor das despesas no firebase
class GetDespesaValor extends StatelessWidget {
  final String documentId;
  const GetDespesaValor({super.key, required this.documentId});

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
          return Text(
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            ).format(double.parse('${data['valor']}')),
          );
        }
        return Text('Carregando...');
      },
    );
  }
}
