import 'package:flutter/material.dart';

class Botao {
  //cria botão
  criaButton(controladorFormulario, funcao, texto, cor, corTexto) {
    return SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          style: ButtonStyle(
            maximumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
            minimumSize: MaterialStateProperty.all(Size(double.infinity, 0)),
            backgroundColor: MaterialStatePropertyAll<Color>(cor),
          ),
          onPressed: () {
            if (controladorFormulario.currentState!.validate()) {
              funcao();
            }
          },
          child: Text(
            texto,
            style: TextStyle(
              color: corTexto,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
