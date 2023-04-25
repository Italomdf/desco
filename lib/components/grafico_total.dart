import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:desco/components/textos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

//cria grafico para pagina de despesas totais
class GraficoTotal extends StatefulWidget {
  final DateTime firstDate;
  final DateTime endDate;
  double min;
  double max;

  GraficoTotal({
    Key? key,
    required this.firstDate,
    required this.min,
    required this.max,
    required this.endDate,
  });

  @override
  State<GraficoTotal> createState() => _GraficoTotalState();
}

class _GraficoTotalState extends State<GraficoTotal> {
  var _tooltipBehavior = TooltipBehavior(enable: true);
  double totalCasa = 0;
  double totalCarro = 0;
  double totalMercado = 0;
  double totalOutros = 0;
  double total = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void mostraTotalcasa(startDate, endDate, max, min, tipo) async {
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
      totalCasa = totalValor;
    });
  }

  void mostraTotalMercado(startDate, endDate, max, min, tipo) async {
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
      totalMercado = totalValor;
    });
  }

  void mostraTotalcarro(startDate, endDate, max, min, tipo) async {
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
      totalCarro = totalValor;
    });
  }

  void mostraTotaloutros(startDate, endDate, max, min, tipo) async {
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
      totalOutros = totalValor;
    });
  }

  @override
  Widget build(BuildContext context) {
    mostraTotalMercado(
        widget.firstDate, widget.endDate, widget.max, widget.min, 'me');
    mostraTotalcarro(
        widget.firstDate, widget.endDate, widget.max, widget.min, 'car');
    mostraTotalcasa(
        widget.firstDate, widget.endDate, widget.max, widget.min, 'ca');
    mostraTotaloutros(
        widget.firstDate, widget.endDate, widget.max, widget.min, 'ou');
    final List<ChartDataTotalDespezas> chartDataTotalDespezas = [
      ChartDataTotalDespezas(
          'Casa', totalCasa, Color.fromARGB(255, 88, 80, 141)),
      ChartDataTotalDespezas('Mercado', totalMercado, Colors.green.shade700),
      ChartDataTotalDespezas(
          'Carro', totalCarro, Color.fromARGB(255, 0, 117, 172)),
      ChartDataTotalDespezas('Outros', totalOutros, Colors.blueGrey)
    ];

    final _currencyFormat = NumberFormat.simpleCurrency(locale: "pt_BR");

    return Scaffold(
      body: Center(
        child: (totalCarro + totalOutros + totalMercado + totalCasa == 0)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Textos().criaTexto(
                      'Nenhuma despesa encontrada\n inclua uma despesa no botão abaixo\nou altere os filtros',
                      Colors.amber.shade700,
                      15,
                      TextAlign.center)
                ],
              )
            : SfCircularChart(
                annotations: [
                  CircularChartAnnotation(
                    widget: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Icon(
                          Icons.money_off,
                          size: constraints.maxHeight * .3,
                          color: Color.fromARGB(255, 253, 177, 100),
                        );
                      },
                    ),
                  ),
                ],
                legend: Legend(
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.top,
                  isVisible: true,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                tooltipBehavior: _tooltipBehavior,
                series: <CircularSeries>[
                  // Renders doughnut chart
                  DoughnutSeries<ChartDataTotalDespezas, String>(
                      explode: true,
                      dataSource: chartDataTotalDespezas,
                      pointColorMapper: (ChartDataTotalDespezas data, _) =>
                          data.color,
                      xValueMapper: (ChartDataTotalDespezas data, _) => data.x,
                      enableTooltip: true,
                      dataLabelMapper: (ChartDataTotalDespezas data, _) =>
                          "${data.x}\n${_currencyFormat.format(data.y)}",
                      dataLabelSettings: const DataLabelSettings(
                          isVisible: true, textStyle: TextStyle(fontSize: 15)),
                      yValueMapper: (ChartDataTotalDespezas data, _) => data.y),
                ],
              ),
      ),
    );
  }
}

class ChartDataTotalDespezas {
  ChartDataTotalDespezas(this.x, this.y, [this.color = Colors.transparent]);
  final String x;
  double? y;
  final Color color;
}
