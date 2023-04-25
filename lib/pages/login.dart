import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:desco/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

//tela de login
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  Duration get loginTime => const Duration(milliseconds: 2250);

  //cria usuario
  Future<String?> createUser(SignupData data) async {
    try {
      final _auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name.toString(),
        password: data.password.toString(),
      );
      var firebaseUser = await FirebaseAuth.instance.currentUser;
      FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUser!.uid)
          .set({'email': data.name, 'senha:': data.password});
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'A senha é muito curta, deve ter no mínimo 6 caracteres.';
      } else if (e.code == 'email-already-in-use') {
        return 'Email ${data.name} já existe.';
      }
    } catch (e) {
      print(e);
    }
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {}
    });
    return null;
  }

  //recupera senha
  Future<String?> recoverPassword(String name) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Usuario não encontrado.';
      }
    }
    return null;
  }

  //loga usuario
  Future<String?> loginUser(LoginData data) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      // Navigate to home page or do something else after successful login
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Usuario não encontrado para esse email.';
      } else if (e.code == 'wrong-password') {
        return 'Senha incorreta para esse usuario.';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      theme: LoginTheme(
        primaryColor: Colors.green,
        pageColorDark: Colors.blueGrey,
        accentColor: Colors.greenAccent.shade100,
        errorColor: Colors.deepOrange,
        // ignore: prefer_const_constructors
        titleStyle: TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'Quicksand',
          letterSpacing: 4,
        ),
        // ignore: prefer_const_constructors
        bodyStyle: TextStyle(
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
        ),
        // ignore: prefer_const_constructors
        textFieldStyle: TextStyle(
          color: Colors.green.shade700,
        ),
        buttonStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.amber,
        ),
        cardTheme: CardTheme(
          color: Colors.blueGrey.shade100,
          elevation: 30,
          // ignore: prefer_const_constructors
          margin: EdgeInsets.only(top: 15),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.green.withOpacity(.1),
          contentPadding: EdgeInsets.zero,
          // ignore: prefer_const_constructors
          errorStyle: TextStyle(
            color: Colors.deepOrange,
          ),
          // ignore: prefer_const_constructors
          labelStyle: TextStyle(fontSize: 12),
          // ignore: prefer_const_constructors
          disabledBorder: UnderlineInputBorder(
            // ignore: prefer_const_constructors
            borderSide: BorderSide(color: Colors.grey, width: 5),
          ),
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: Colors.blue,
          backgroundColor: Colors.green,
          highlightColor: Colors.lightGreen,
          elevation: 9.0,
          highlightElevation: 6.0,
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
        ),
      ),
      title: 'Desco',
      // ignore: prefer_const_constructors
      logo: AssetImage('assets/images/mini.png'), onLogin: loginUser,
      onSignup: createUser,
      onSubmitAnimationCompleted: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      },
      onRecoverPassword: recoverPassword,
    );
  }
}
