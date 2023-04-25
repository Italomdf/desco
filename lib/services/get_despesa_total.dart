import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//pega valor total das despesas no firebase
class GetDespesaTotal extends StatelessWidget {
  const GetDespesaTotal({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference despesas = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('despesas');

    return FutureBuilder<DocumentSnapshot>(
      future: despesas.doc().get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return (data['valor']);
        }
        return Text('loading...');
      },
    );
  }
}
