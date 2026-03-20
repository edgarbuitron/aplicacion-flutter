import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({required this.title, super.key});

  // Los campos en una subclase de Widget siempre se marcan como "final".
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // en píxeles lógicos
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.blue[500]),
      // Row es un diseño lineal horizontal.
      child: Row(
        children: [
          const IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Navigation menu', // <-- Comillas simples corregidas aquí
            onPressed: null, // null deshabilita el botón
          ),
          // Expanded expande su hijo para llenar el espacio disponible.
          Expanded(child: title),
          const IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search', // <-- Comillas simples corregidas aquí
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    // Material es una hoja de papel conceptual sobre la que aparece la UI.
    return Material(
      // Column es un diseño lineal vertical.
      child: Column(
        children: [
          MyAppBar(
            title: Text(
              'Example title', // <-- Comillas simples corregidas aquí
              style: Theme.of(context).primaryTextTheme.titleLarge,
            ),
          ),
          const Expanded(
            child: Center(
              child:
                  Text('Hello, world!'), // <-- Comillas simples corregidas aquí
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      title: 'My app', // <-- Comillas simples corregidas aquí
      home: SafeArea(child: MyScaffold()),
      debugShowCheckedModeBanner:
          false, // Opcional: quita la etiqueta de "DEBUG"
    ),
  );
}
