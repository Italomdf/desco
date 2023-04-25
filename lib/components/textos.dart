import 'dart:ui';
import 'package:flutter/material.dart';

class Textos {
  //cria texto qualquer
  criaTexto(texto, cor, double tamanho, alinhamento) {
    return Text(
      texto,
      textAlign: alinhamento,
      style: TextStyle(
        color: cor,
        fontSize: tamanho,
      ),
    );
  }

  //cria texto específico para topo da pagina
  criaTitulo(texto, cor, double tamanho, alinhamento) {
    return Text(
      texto,
      textAlign: alinhamento,
      style: TextStyle(
        fontSize: tamanho,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 0, 53, 84),
      ),
    );
  }

  //cria inputs gerais
  criaInputFire(
      teclado, formatador, habilitado, controlador, label, cor, dica) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        keyboardType: teclado,
        inputFormatters: formatador,
        autofocus: true,
        controller: controlador,
        decoration: InputDecoration(
          hintText: dica,
          floatingLabelStyle: TextStyle(color: cor),
          labelStyle: TextStyle(color: cor),
          labelText: label,
          enabled: habilitado,
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: cor)),
          focusedBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: cor)),
        ),
      ),
    );
  }
}
