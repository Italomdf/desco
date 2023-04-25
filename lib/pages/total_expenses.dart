import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:desco/components/grafico_total.dart';
import 'package:desco/components/listaFire.dart';
import 'package:desco/pages/login.dart';
import 'package:desco/util/util.dart';

//tela de todas as depesas
class TotalExpenses extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TotalExpenses({super.key});

  @override
  State<TotalExpenses> createState() => _TotalExpensesState();
}

class _TotalExpensesState extends State<TotalExpenses> {
  GlobalKey<FormState> formController = GlobalKey<FormState>();
  TextEditingController txtDescricao = TextEditingController();
  TextEditingController txtValor = TextEditingController();
  TextEditingController txtData = TextEditingController();
  TextEditingController txtTipo = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime startDate = DateTime.now().subtract(Duration(days: 365));
  DateTime endDate = Util.getEndDate();
  double max = 17976931348623157E+308;
  double min = 0.0;
  List<String> docIDs = [];
  String textoDatas = 'Filtrar Data';
  String textoValor = 'Filtrar Valor';

  var _graficoState = GraficoTotal(
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      min: 0.0,
      max: 17976931348623157E+308,
      endDate: Util.getEndDate());

  //formata int para moeda real
  final _currencyFormat = NumberFormat.simpleCurrency(locale: "pt_BR");

  //atualiza periodo do filtro
  void _updateDateRange(DateTime start, DateTime end) {
    setState(() {
      startDate = start;
      endDate = end;

      textoDatas =
          "${DateFormat('d MMM').format(startDate)} - ${DateFormat('d MMM').format(endDate)}";

      _graficoState = GraficoTotal(
          firstDate: startDate, min: min, max: max, endDate: endDate);
    });
  }

  //atualiza filtro de valores
  void _updateValor(double novoMin, double novoMax) {
    setState(() {
      min = novoMin;
      max = novoMax;

      textoValor =
          "${_currencyFormat.format(min)} - ${_currencyFormat.format(max)}";
      _graficoState = GraficoTotal(
          firstDate: startDate, min: min, max: max, endDate: endDate);
    });
  }

  //formata data
  var maskFormatter = MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  //faz logout do usuario
  _signOut() async {
    await _auth.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: ((context) => Login())));
  }

  @override
  Widget build(BuildContext context) {
    final _currencyFormat = NumberFormat.simpleCurrency(locale: "pt_BR");

    var maskFormatter = MaskTextInputFormatter(
        mask: '##/##/####',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);

    return Scaffold(
      body: SafeArea(
        child: Form(
            key: formController,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.money_off,
                          color: Color.fromARGB(255, 0, 53, 84),
                        )),
                    pegaTotal(
                      textoTipo: 'Total',
                      startDate: startDate,
                      max: max,
                      min: min,
                      endDate: endDate,
                    ),
                    IconButton(
                      color: Color.fromARGB(255, 0, 53, 84),
                      onPressed: _signOut,
                      icon: Icon(Icons.logout),
                    ),
                  ],
                ),
                Expanded(child: _graficoState),
                Filtros(
                    corBackground: Colors.amber.shade700,
                    startDate: startDate,
                    max: max,
                    min: min,
                    endDate: endDate,
                    corTexto: Colors.black,
                    textoDatas: textoDatas,
                    textoValor: textoValor,
                    updateValor: _updateValor,
                    updateState: _updateDateRange),
                Expanded(
                  child: Container(
                    child: FutureBuilder(
                        future: Util().getListaTotal(
                            docIDs, startDate, endDate, max, min),
                        builder: (context, indice) {
                          return ListaFire(
                              updateState: () => setState(() {}),
                              corTexto: Colors.black,
                              corBackground: Colors.amber.shade700,
                              txtDescricao: txtDescricao,
                              txtValor: txtValor,
                              txtData: txtData,
                              docIDs: docIDs,
                              formController: formController);
                        }),
                  ),
                ),
                CadastroTotal(
                    txtTipo: txtTipo,
                    updateState: () => setState(() {}),
                    txtData: txtData,
                    tipo: 'ou',
                    txtDescricao: txtDescricao,
                    formController: formController,
                    txtValor: txtValor,
                    corBackground: Colors.amber.shade700,
                    corTexto: Colors.black)
              ],
            )),
      ),
    );
  }
}
