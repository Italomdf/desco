import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:desco/components/botao.dart';
import 'package:desco/components/textos.dart';

class Util {
  //pega dia atual
  static DateTime getEndDate() {
    return DateTime.now();
  }

  //limpa campos :)
  limpaCampos(txtData, txtDescricao, txtValor) {
    txtData.text = '';
    txtDescricao.text = '';
    txtValor.text = '';
  }

  //pega dados de TODAS as despesas do firebase e popula lista(sem filtro de tipo)
  Future<List<String>> getListaTotal(
      docIDs, startDate, endDate, max, min) async {
    docIDs.clear();
    var firebaseUser = await FirebaseAuth.instance.currentUser;

    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .collection('despesas')
        .where('data', isGreaterThanOrEqualTo: startDate)
        .where('data', isLessThanOrEqualTo: endDate)
        .get();

    for (var document in snapshot.docs) {
      var valor = document.data()['valor'];
      if (valor >= min && valor <= max) {
        docIDs.add(document.reference.id);
      }
    }

    return docIDs;
  }

  //pega dados das despesas do firebase e popula lista (com filtro de tipo)
  Future<List<String>> getLista(
      tipo, docIDs, startDate, endDate, max, min) async {
    docIDs.clear();
    var firebaseUser = await FirebaseAuth.instance.currentUser;

    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .collection('despesas')
        .where('tipo', isEqualTo: tipo)
        .where('data', isGreaterThanOrEqualTo: startDate)
        .where('data', isLessThanOrEqualTo: endDate)
        .get();

    for (var document in snapshot.docs) {
      var valor = document.data()['valor'];
      if (valor >= min && valor <= max) {
        docIDs.add(document.reference.id);
      }
    }

    return docIDs;
  }

  //Pega dados da despesa selecionada e preenche textfield com dados selecionados (para initial value no alterar despesa)
  pegaDadosDespesa(documentId, txtDescricao, txtValor, txtData) async {
    //pega dados da deespesa selecionada
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference despesas = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('despesas');

    DocumentSnapshot snapshot = await despesas.doc(documentId).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    //preenche textfield
    txtDescricao.text = '${data['descricao']}';
    txtValor.text = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(double.parse('${data['valor']}'));
    DateTime date = data['data'].toDate();
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    txtData.text = formattedDate;
  }

  //cadastra despesa no firebasefirestore
  cadastrofire(
      formController, txtDescricao, txtValor, txtData, _auth, tipo, context) {
    if (formController.currentState!.validate() &
        txtDescricao.text.isNotEmpty &
        txtValor.text.isNotEmpty &
        txtData.text.isNotEmpty) {
      DateTime date = DateFormat('dd/MM/yyyy').parse(txtData.text);

      Timestamp timestamp = Timestamp.fromDate(date);
      String docID = _auth.currentUser!.uid;
      var db = FirebaseFirestore.instance.collection('users').doc(docID);
      db.collection('despesas').add({
        'tipo': tipo,
        'valor': double.parse(txtValor.text
            .replaceAll(RegExp(r'[^\d.,]'), "")
            .replaceAll('.', '')
            .replaceAll(',', '.')),
        'descricao': txtDescricao.text,
        'data': timestamp
      });
      Navigator.pop(context);
    } else {
      final snackBar = SnackBar(
        content: Text('Por favor preencha todos os campos'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red, // Specify the behavior here
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

//abre seletor de data e implementa data para cadastro ou update de usuario
class SelecionaData extends StatefulWidget {
  Color? corBackground;
  Color? corTexto;
  TextEditingController txtData = TextEditingController();
  SelecionaData({
    Key? key,
    required this.txtData,
    required this.corBackground,
    required this.corTexto,
  });

  @override
  State<SelecionaData> createState() => _SelecionaDataState();
}

class _SelecionaDataState extends State<SelecionaData> {
  String textoDatas = 'Data';

  @override
  Widget build(BuildContext context) {
    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        locale: Locale('pt', 'BR'),
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime.now().add(Duration(days: 60)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: widget.corBackground!,
                onPrimary: widget.corTexto!,
                surface: widget.corBackground!,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: Colors.blueGrey[900],
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        setState(() {
          widget.txtData.text = DateFormat('dd/MM/yyyy').format(picked);
          textoDatas = "${DateFormat('d MMM').format(picked)}";
        });
      }
    }

    return ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStatePropertyAll(0),
            backgroundColor: MaterialStatePropertyAll(Colors.transparent)),
        onPressed: () {
          selectDate(context);
        },
        child: Row(
          children: [
            Icon(color: widget.corTexto, Icons.calendar_month_outlined),
            Textos()
                .criaTexto(textoDatas, widget.corTexto, 15, TextAlign.center),
          ],
        ));
  }
}

//(retorna botão de cadastro tipos) mostra Dialogo para cadastro de usuário (cadstro com tipos pré fornecidos)
class DialogoCadastro extends StatefulWidget {
  Color? corBackground;
  Color? corTexto;
  TextEditingController txtData = TextEditingController();
  TextEditingController txtDescricao = TextEditingController();
  TextEditingController txtValor = TextEditingController();
  GlobalKey<FormState> formController = GlobalKey<FormState>();
  String tipo;
  final Function updateState;

  DialogoCadastro(
      {Key? key,
      required this.txtData,
      required this.tipo,
      required this.txtDescricao,
      required this.formController,
      required this.txtValor,
      required this.corBackground,
      required this.corTexto,
      required this.updateState});

  @override
  State<DialogoCadastro> createState() => _DialogoCadastroState();
}

class _DialogoCadastroState extends State<DialogoCadastro> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    mostrarDialogoCadastro() {
      Util().limpaCampos(widget.txtData, widget.txtDescricao, widget.txtValor);
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy').format(now);
      widget.txtData.text = formattedDate.toString();
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
                Textos().criaInputFire(TextInputType.text, null, true,
                    widget.txtDescricao, "Descrição", widget.corTexto, ''),
                Textos().criaInputFire(
                    TextInputType.number,
                    [
                      CurrencyTextInputFormatter(symbol: 'R\$', locale: 'pt-BR')
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
                ),
                IconButton(
                    onPressed: () {
                      Util().cadastrofire(
                          widget.formController,
                          widget.txtDescricao,
                          widget.txtValor,
                          widget.txtData,
                          _auth,
                          widget.tipo,
                          context);

                      widget.updateState();
                    },
                    // ignore: prefer_const_constructors
                    icon: Icon(
                      Icons.add_box_outlined,
                      color: widget.corTexto,
                    )),
              ],
            ),
            actions: <Widget>[],
          );
        },
      );
    }

    return Botao().criaButton(widget.formController, mostrarDialogoCadastro,
        "Incluir despesa", widget.corBackground, widget.corTexto);
  }
}

//retorna row com botões de filtro, cria filtros
class Filtros extends StatefulWidget {
  final Function(DateTime start, DateTime end) updateState;
  final Function(double novoMin, double novoMax) updateValor;
  Color? corBackground;
  Color? corTexto;
  DateTime startDate;
  DateTime endDate;
  String textoDatas = 'Filtrar';
  String textoValor = 'Filtrar';
  double max;
  double min;
  Filtros(
      {Key? key,
      required this.corBackground,
      required this.startDate,
      required this.max,
      required this.min,
      required this.endDate,
      required this.corTexto,
      required this.textoDatas,
      required this.textoValor,
      required this.updateValor,
      required this.updateState});

  @override
  State<Filtros> createState() => _FiltrosState();
}

class _FiltrosState extends State<Filtros> {
  @override
  Widget build(BuildContext context) {
    TextEditingController txtMax = TextEditingController();
    TextEditingController txtMin = TextEditingController();
    //filtra despesas por período
    Future<void> selectRangeDate(BuildContext context) async {
      DateTimeRange? picked = await showDateRangePicker(
        context: context,
        locale: Locale('pt', 'BR'),
        firstDate: DateTime(2015),
        lastDate: DateTime.now().add(Duration(days: 60)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: widget.corBackground!,
                onPrimary: widget.corTexto!,
                surface: widget.corBackground!,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: Colors.blueGrey[900],
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        String formattedStartDate =
            DateFormat('yyyy-MM-dd').format(picked.start);
        String formattedEndDate = DateFormat('yyyy-MM-dd').format(picked.end);
        DateTime newStartDate = DateTime.parse(formattedStartDate);
        DateTime newEndDate = DateTime.parse(formattedEndDate);
        widget.startDate = newStartDate;
        widget.endDate = newEndDate;
        widget.updateState(newStartDate, newEndDate);
      }
    }

    //seleciona valor para filtro
    Future<void> selecionaValor() async {
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
                    TextInputType.number,
                    [
                      CurrencyTextInputFormatter(symbol: 'R\$', locale: 'pt-BR')
                    ],
                    true,
                    txtMin,
                    "Min",
                    widget.corTexto,
                    ''),
                Textos().criaInputFire(
                    TextInputType.number,
                    [
                      CurrencyTextInputFormatter(symbol: 'R\$', locale: 'pt-BR')
                    ],
                    true,
                    txtMax,
                    "Max",
                    widget.corTexto,
                    ''),
                IconButton(
                    onPressed: () {
                      if (txtMax.text.isNotEmpty & txtMin.text.isNotEmpty) {
                        setState(() {
                          widget.min = double.parse(txtMin.text
                              .replaceAll(RegExp(r'[^\d.,]'), "")
                              .replaceAll('.', '')
                              .replaceAll(',', '.'));
                          widget.max = double.parse(txtMax.text
                              .replaceAll(RegExp(r'[^\d.,]'), "")
                              .replaceAll('.', '')
                              .replaceAll(',', '.'));

                          widget.updateValor(widget.min, widget.max);
                        });
                        Navigator.pop(context);
                      } else {
                        final snackBar = SnackBar(
                          content: Text('Por favor, preencha todos os campos.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor:
                              Colors.red, // Specify the behavior here
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    // ignore: prefer_const_constructors
                    icon: Icon(
                      Icons.save_as_outlined,
                      color: widget.corTexto,
                    )),
              ],
            ),
            actions: <Widget>[],
          );
        },
      );
    }

    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                      elevation: MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.transparent)),
                  onPressed: () {
                    selectRangeDate(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                          color: widget.corBackground,
                          Icons.calendar_month_outlined),
                      Textos().criaTexto(widget.textoDatas,
                          widget.corBackground, 15, TextAlign.center),
                    ],
                  )),
              ElevatedButton(
                  style: ButtonStyle(
                      elevation: MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.transparent)),
                  onPressed: () {
                    selecionaValor();
                  },
                  child: Row(
                    children: [
                      Icon(
                          color: widget.corBackground,
                          Icons.monetization_on_outlined),
                      Textos().criaTexto(widget.textoValor,
                          widget.corBackground, 15, TextAlign.center),
                    ],
                  )),
            ],
          )
        ],
      ),
    );
  }
}

//(retorna texto) Pega valor total por tipo de despesa
class pegaTotalTipos extends StatefulWidget {
  DateTime startDate;
  DateTime endDate;
  double max;
  double min;
  String tipo;
  String textoTipo;
  pegaTotalTipos({
    Key? key,
    required this.startDate,
    required this.max,
    required this.min,
    required this.tipo,
    required this.textoTipo,
    required this.endDate,
  });

  @override
  State<pegaTotalTipos> createState() => _pegaTotalTiposState();
}

class _pegaTotalTiposState extends State<pegaTotalTipos> {
  double totalTipo = 0.0;
  void mostraTotalPorTipo(startDate, endDate, max, min, tipo) async {
    var firebaseUser = FirebaseAuth.instance.currentUser;

    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .collection('despesas')
        .where('tipo', isEqualTo: tipo)
        .where('data', isGreaterThanOrEqualTo: startDate)
        .where('data', isLessThanOrEqualTo: endDate)
        .get();

    var documents = snapshot.docs
        .where(
            (doc) => doc.data()['valor'] >= min && doc.data()['valor'] <= max)
        .toList();

    double totalValor =
        documents.fold(0, (prev, curr) => prev + curr.data()['valor']);

    setState(() {
      totalTipo = totalValor;
    });
  }

  @override
  Widget build(BuildContext context) {
    mostraTotalPorTipo(
        widget.startDate, widget.endDate, widget.max, widget.min, widget.tipo);
    return Textos().criaTitulo(
        "${widget.textoTipo}\n${NumberFormat.currency(
          locale: 'pt_BR',
          symbol: 'R\$',
        ).format(double.parse('$totalTipo'))}",
        Color.fromARGB(255, 0, 53, 84),
        25,
        TextAlign.center);
  }
}

//(retorna texto)Pega valor total
class pegaTotal extends StatefulWidget {
  DateTime startDate;
  DateTime endDate;
  double max;
  double min;
  String textoTipo;
  pegaTotal({
    Key? key,
    required this.startDate,
    required this.max,
    required this.min,
    required this.endDate,
    required this.textoTipo,
  });

  @override
  State<pegaTotal> createState() => _pegaTotalState();
}

class _pegaTotalState extends State<pegaTotal> {
  double total = 0.0;
  void mostraTotal(startDate, endDate, max, min) async {
    var firebaseUser = FirebaseAuth.instance.currentUser;

    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .collection('despesas')
        .where('data', isGreaterThanOrEqualTo: startDate)
        .where('data', isLessThanOrEqualTo: endDate)
        .get();

    var documents = snapshot.docs
        .where(
            (doc) => doc.data()['valor'] >= min && doc.data()['valor'] <= max)
        .toList();

    double totalValor =
        documents.fold(0, (prev, curr) => prev + curr.data()['valor']);

    setState(() {
      total = totalValor;
    });
  }

  @override
  Widget build(BuildContext context) {
    mostraTotal(widget.startDate, widget.endDate, widget.max, widget.min);
    return Textos().criaTitulo(
        "${widget.textoTipo}\n${NumberFormat.currency(
          locale: 'pt_BR',
          symbol: 'R\$',
        ).format(double.parse('$total'))}",
        Color.fromARGB(255, 0, 53, 84),
        25,
        TextAlign.center);
  }
}

//(retorna botão de cadastro total)cadastro de despesas com filtro de tipo para tela de total despesas
class CadastroTotal extends StatefulWidget {
  Color? corBackground;
  Color? corTexto;
  TextEditingController txtData = TextEditingController();
  TextEditingController txtDescricao = TextEditingController();
  TextEditingController txtValor = TextEditingController();
  GlobalKey<FormState> formController = GlobalKey<FormState>();
  TextEditingController txtTipo = TextEditingController();
  String tipo;
  final Function updateState;

  CadastroTotal(
      {Key? key,
      required this.txtData,
      required this.tipo,
      required this.txtDescricao,
      required this.formController,
      required this.txtValor,
      required this.corBackground,
      required this.corTexto,
      required this.txtTipo,
      required this.updateState});

  @override
  State<CadastroTotal> createState() => _CadastroTotalState();
}

class _CadastroTotalState extends State<CadastroTotal> {
  String? selecao;

  @override
  Widget build(BuildContext context) {
    Map<String, String> list = {
      'Casa': 'ca',
      'Mercado': 'me',
      'Carro': 'car',
      'Outros': 'ou'
    };
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String? selecao;

    mostrarDialogoCadastro() {
      Util().limpaCampos(widget.txtData, widget.txtDescricao, widget.txtValor);
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy').format(now);
      widget.txtData.text = formattedDate.toString();
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            backgroundColor: widget.corBackground,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Textos().criaInputFire(TextInputType.text, null, true,
                        widget.txtDescricao, "Descrição", widget.corTexto, ''),
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
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton(
                          hint: Text('Tipo de despesa'),
                          underline: Container(
                            height: 2,
                            color: Colors.black,
                          ),
                          dropdownColor: Colors.amber.shade700,
                          iconEnabledColor: Colors.black,
                          isExpanded: true,
                          value: selecao,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          onChanged: (String? value) {
                            setState(() {
                              selecao = value;
                              widget.tipo = list[value] ?? '';
                              widget.txtTipo.text = value.toString();
                            });
                          },
                          items: list.entries
                              .map<DropdownMenuItem<String>>((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.key),
                            );
                          }).toList(),
                        )),
                    IconButton(
                      onPressed: () {
                        Util().cadastrofire(
                            widget.formController,
                            widget.txtDescricao,
                            widget.txtValor,
                            widget.txtData,
                            _auth,
                            widget.tipo,
                            context);

                        widget.updateState();
                      },
                      // ignore: prefer_const_constructors
                      icon: Icon(
                        Icons.add_box_outlined,
                        color: widget.corTexto,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SelecionaData(
                            txtData: widget.txtData,
                            corBackground: widget.corBackground,
                            corTexto: widget.corTexto),
                      ],
                    ),
                  ],
                );
              },
            ),
            actions: <Widget>[],
          );
        },
      );
    }

    return Botao().criaButton(widget.formController, mostrarDialogoCadastro,
        "Incluir despesa", widget.corBackground, widget.corTexto);
  }
}
