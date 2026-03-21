import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 PON TUS LLAVES REALES DE FIREBASE AQUÍ 👇
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyB0ehcK7rAsYUw9JRHfZ6PFkiN6om91T8E",
        authDomain: "proyecto-scada-bc568.firebaseapp.com",
        projectId: "proyecto-scada-bc568",
        storageBucket: "proyecto-scada-bc568.firebasestorage.app",
        messagingSenderId: "894366577606",
        appId: "1:894366577606:web:2ffffbbddf39dc9cad38c7"),
  );
  // 👆 -------------------------------------- 👆

  // Activamos la persistencia (modo sin internet)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MiAppScada());
}

// 1. Configuración principal de la App
class MiAppScada extends StatelessWidget {
  const MiAppScada({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCADA CRUD',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PanelControl(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 2. Pantalla principal donde ocurre la magia (StatefulWidget permite cambios en vivo)
class PanelControl extends StatefulWidget {
  const PanelControl({super.key});

  @override
  State<PanelControl> createState() => _PanelControlState();
}

class _PanelControlState extends State<PanelControl> {
  // Conectamos con una "carpeta" en Firebase llamada "sensores"
  final CollectionReference coleccionSensores =
      FirebaseFirestore.instance.collection('sensores');

  // Controladores para leer lo que escribes en las cajas de texto
  final TextEditingController _controladorNombre = TextEditingController();
  final TextEditingController _controladorValor = TextEditingController();

  // [C]REAR y [A]CTUALIZAR: Muestra una ventanita para ingresar datos
  void _mostrarVentana([DocumentSnapshot? documentoActual]) {
    // Si pasamos un documento, es porque vamos a Editar. Llenamos las cajas de texto.
    if (documentoActual != null) {
      _controladorNombre.text = documentoActual['nombre'];
      _controladorValor.text = documentoActual['valor'];
    } else {
      // Si es nuevo, limpiamos las cajas.
      _controladorNombre.clear();
      _controladorValor.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(documentoActual == null ? 'Nuevo Sensor' : 'Editar Sensor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controladorNombre,
              decoration:
                  const InputDecoration(labelText: 'Nombre (ej. Motor 1)'),
            ),
            TextField(
              controller: _controladorValor,
              decoration: const InputDecoration(labelText: 'Valor (ej. 45°C)'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final String nombre = _controladorNombre.text;
              final String valor = _controladorValor.text;

              if (nombre.isNotEmpty && valor.isNotEmpty) {
                if (documentoActual == null) {
                  // Acción de CREAR en Firebase
                  await coleccionSensores
                      .add({'nombre': nombre, 'valor': valor});
                } else {
                  // Acción de ACTUALIZAR en Firebase
                  await coleccionSensores
                      .doc(documentoActual.id)
                      .update({'nombre': nombre, 'valor': valor});
                }
                // Limpiamos y cerramos la ventana
                _controladorNombre.clear();
                _controladorValor.clear();
                Navigator.of(context).pop();
              }
            },
            child: Text(documentoActual == null ? 'Guardar' : 'Actualizar'),
          )
        ],
      ),
    );
  }

  // [E]LIMINAR: Borra un documento de Firebase
  void _eliminarSensor(String idDocumento) async {
    await coleccionSensores.doc(idDocumento).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel SCADA - En Vivo'),
        backgroundColor: Colors.blue[700],
      ),
      // [L]EER: StreamBuilder es un "tubo" conectado a Firebase que escucha cambios en tiempo real
      body: StreamBuilder(
        stream: coleccionSensores.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documento =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documento['nombre'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Lectura: ${documento['valor']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de Editar
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarVentana(documento),
                        ),
                        // Botón de Eliminar
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarSensor(documento.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          // Si no hay datos aún, mostramos una bolita cargando
          return const Center(child: CircularProgressIndicator());
        },
      ),
      // Botón flotante para Crear
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarVentana(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
