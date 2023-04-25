import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:desco/components/textos.dart';
import 'package:desco/services/get_depesa_valor.dart';
import 'package:desco/services/get_despesa_descricao.dart';
import 'package:desco/services/get_despesa_time.dart';
import 'package:desco/util/util.dart';

//cria lista de despesas
class ListaFire extends StatefulWidget {
  TextEditingController txtDescricao = TextEditingController();
  TextEditingController txtValor = TextEditingController();
  TextEditingController txtData = TextEditingController();
  GlobalKey<FormState> formController = GlobalKey<FormState>();
  List<String> docIDs;
  Color? corBackground;
  Color? corTexto;
  final Function updateState;

  ListaFire(
      {Key? key,
      required this.txtDescricao,
      required this.txtValor,
      required this.txtData,
      required this.docIDs,
      required this.corBackground,
      required this.corTexto,
      required this.updateState,
      required this.formController})
      : super(key: key);

  @override
  State<ListaFire> createState() => _ListaFireState();
}

class _ListaFireState extends State<ListaFire> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.docIDs.length,
      itemBuilder: (context, indice) {
        return Card(
          color: widget.corBackground,
          elevation: 50,
          margin: const EdgeInsets.all(5),
          child: Column(
            children: [
              ListTile(
                textColor: widget.corTexto,
                title: GetDespesaDescricao(documentId: widget.docIDs[indice]),
                subtitle: GetDespesasTime(documentId: widget.docIDs[indice]),
                trailing: GetDespesaValor(documentId: widget.docIDs[indice]),
                onTap: () {
                  Util().pegaDadosDespesa(widget.docIDs[indice],
                      widget.txtDescricao, widget.txtValor, widget.txtData);
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        backgroundColor: widget.corBackground,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Textos().criaInputFire(
                                TextInputType.text,
                                null,
                                true,
                                widget.txtDescricao,
                                "Descrição",
                                widget.corTexto,
                                ''),
                            Textos().criaInputFire(
                                TextInputType.number,
                                [
                                  CurrencyTextInputFormatter(
                                      symbol: 'R\$', locale: 'pt-BR')
                                ],
                                true,
                                widget.txtValor,
                                "Valor",
                                widget.corTexto,
                                ''),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SelecionaData(
                                    txtData: widget.txtData,
                                    corBackground: widget.corBackground,
                                    corTexto: widget.corTexto)
                              ],
                            )
                          ],
                        ),
                        actions: <Widget>[
                          IconButton(
                              onPressed: () {
                                if (widget.formController.currentState!
                                        .validate() &
                                    widget.txtDescricao.text.isNotEmpty &
                                    widget.txtValor.text.isNotEmpty &
                                    widget.txtData.text.isNotEmpty) {
                                  DateTime date = DateFormat('dd/MM/yyyy')
                                      .parse(widget.txtData.text);
                                  Timestamp timestamp =
                                      Timestamp.fromDate(date);
                                  String docID = _auth.currentUser!.uid;
                                  var db = FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(docID);
                                  db
                                      .collection('despesas')
                                      .doc(widget.docIDs[indice])
                                      .update({
                                    'valor': double.parse(widget.txtValor.text
                                        .replaceAll(RegExp(r'[^\d.,]'), "")
                                        .replaceAll('.', '')
                                        .replaceAll(',', '.')),
                                    'descricao': widget.txtDescricao.text,
                                    'data': timestamp
                                  });

                                  Navigator.of(context).pop();
                                  setState(() {});
                                } else {
                                  // ignore: prefer_const_constructors
                                  final snackBar = SnackBar(
                                      backgroundColor: Colors.red,
                                      // ignore: prefer_const_constructors
                                      content: Text(
                                          'Por favor, preencha todos os campos.'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                              // ignore: prefer_const_constructors
                              icon: Icon(
                                Icons.change_circle_outlined,
                                color: widget.corTexto,
                              )),
                          IconButton(
                              onPressed: () async {
                                var firebaseUser =
                                    FirebaseAuth.instance.currentUser;
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(firebaseUser!.uid)
                                    .collection('despesas')
                                    .doc(widget.docIDs[indice])
                                    .delete();

                                widget.docIDs.removeAt(indice);

                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                                setState(() {});
                              },
                              // ignore: prefer_const_constructors
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red.shade900,
                              )),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
