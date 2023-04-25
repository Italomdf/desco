import 'package:flutter/material.dart';

class AppBarComponent {
  //cria barra embaixo do app para lista de paginas
  createAppBar() {
    return BottomAppBar(
      color: Colors.green.shade800,
      child: const TabBar(
        indicatorColor: Colors.amber,
        tabs: [
          Tab(
              icon: Icon(
            Icons.monetization_on_outlined,
            color: Color.fromARGB(255, 0, 53, 84),
          )),
          Tab(
              icon: Icon(
            Icons.house,
            color: Color.fromARGB(255, 0, 53, 84),
          )),
          Tab(
              icon: Icon(
            Icons.shopping_cart_outlined,
            color: Color.fromARGB(255, 0, 53, 84),
          )),
          Tab(
              icon: Icon(
            Icons.directions_car,
            color: Color.fromARGB(255, 0, 53, 84),
          )),
          Tab(
              icon: Icon(
            Icons.help_outline_sharp,
            color: Color.fromARGB(255, 0, 53, 84),
          )),
        ],
      ),
/*       title: Center(
        child: Text(
          inputTitle,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 0, 53, 84)),
        ),
      ), */
    );
  }
}
