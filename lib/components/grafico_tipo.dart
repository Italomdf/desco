import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

//cria grafico para paginas de tipos especificos
class GraficoTipo extends StatefulWidget {
  final DateTime firstDate;
  final DateTime endDate;
  double min;
  double max;
  String tipo;
  Color? cor;
  String textoTipo;
  GraficoTipo({
    Key? key,
    required this.firstDate,
    required this.min,
    required this.max,
    required this.tipo,
    required this.cor,
    required this.textoTipo,
    required this.endDate,
  });
  @override
  State<GraficoTipo> createState() => _GraficoTipoState();
}

class _GraficoTipoState extends State<GraficoTipo> {
  double totalCasa = 0;
  double total = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
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
      totalCasa = totalValor;
    });
  }

  void getSum(startDate, endDate, max, min) async {
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

  Widget build(BuildContext context) {
    final List<ChartDataCasa> chartDataCasa = [
      ChartDataCasa(
          '',
          "Total\n${NumberFormat.currency(
            locale: 'pt_BR',
            symbol: 'R\$',
          ).format(double.parse('$total'))}",
          total,
          Colors.amber.shade600),
    ];

    final List<ChartDataCasa> newChartData = [
      ChartDataCasa(
          '',
          "${widget.textoTipo}\n${NumberFormat.currency(
            locale: 'pt_BR',
            symbol: 'R\$',
          ).format(double.parse('$totalCasa'))}",
          totalCasa,
          widget.cor!),
    ];
    mostraTotalPorTipo(
        widget.firstDate, widget.endDate, widget.max, widget.min, widget.tipo);
    getSum(widget.firstDate, widget.endDate, widget.max, widget.min);
    return Scaffold(
      body: Center(
        child: SfCartesianChart(
          primaryXAxis:
              CategoryAxis(labelStyle: TextStyle(color: Colors.black)),
          series: <CartesianSeries>[
            ColumnSeries<ChartDataCasa, String>(
              enableTooltip: false,
              dataLabelMapper: (ChartDataCasa data, _) => data.label,
              dataLabelSettings: const DataLabelSettings(
                  isVisible: true, textStyle: TextStyle(color: Colors.black)),
              pointColorMapper: (ChartDataCasa data, _) => data.color,
              dataSource: chartDataCasa,
              xValueMapper: (ChartDataCasa data, _) => data.month,
              yValueMapper: (ChartDataCasa data, _) => data.y,
            ),
            ColumnSeries<ChartDataCasa, String>(
              dataSource: newChartData,
              pointColorMapper: (ChartDataCasa data, _) => data.color,
              xValueMapper: (ChartDataCasa data, _) => data.month,
              yValueMapper: (ChartDataCasa data, _) => data.y,
              enableTooltip: false,
              dataLabelMapper: (ChartDataCasa data, _) => data.label,
              dataLabelSettings: const DataLabelSettings(
                textStyle: TextStyle(color: Colors.black),
                labelAlignment: ChartDataLabelAlignment.outer,
                isVisible: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartDataCasa {
  ChartDataCasa(this.month, this.label, this.y,
      [this.color = Colors.transparent]);
  final String month;
  final String label;
  final double? y;
  final Color color;
}

class NewChartDataCasa {
  NewChartDataCasa(this.month, this.label, this.y,
      [this.color = Colors.transparent]);
  final String month;
  final String label;
  final double? y;
  final Color color;
}
