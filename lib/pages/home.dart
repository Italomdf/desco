import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:desco/components/app_bar.dart';
import 'package:desco/pages/despesas_carro.dart';
import 'package:desco/pages/despesas_casa.dart';
import 'package:desco/pages/despesas_mercado.dart';
import 'package:desco/pages/despesas_outros.dart';
import 'package:desco/pages/login.dart';
import 'package:desco/pages/total_expenses.dart';

//homepage contendo tabBar com outras telas
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //faz logout
  _signOut() async {
    await _auth.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: ((context) => Login())));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        // ignore: prefer_const_constructors
        body: TabBarView(
          children: [
            TotalExpenses(),
            DespesasCasa(),
            DespesasMercado(),
            DespesasCarro(),
            DespesasOutros(),
          ],
        ),
        bottomNavigationBar: AppBarComponent().createAppBar(),
      ),
    );
  }
}
