import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estudiante.dart';
import '../providers/lugares_provider.dart';
import '../widgets/favorito_boton.dart';
import 'formulario_screen.dart';

class ListaLugaresScreen extends StatefulWidget {
  const ListaLugaresScreen({super.key});

  @override
  State<ListaLugaresScreen> createState() => _ListaLugaresScreenState();
}

class _ListaLugaresScreenState extends State<ListaLugaresScreen> {
  final _busquedaCtrl = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LugaresProvider>().cargarLugares();
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LugaresProvider>();

    // Nota del autor: agregue el buscador filtrando la lista en memoria por
    // nombre (sin distinguir mayusculas), sin tocar la base de datos.
    final lugaresFiltrados = provider.lugares
        .where((l) => l.nombre.toLowerCase().contains(_filtro.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lugares UIDE'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              estudianteNombre,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _busquedaCtrl,
              decoration: InputDecoration(
                labelText: 'Buscar lugar por nombre',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _filtro.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busquedaCtrl.clear();
                          setState(() => _filtro = '');
                        },
                      ),
              ),
              onChanged: (valor) => setState(() => _filtro = valor),
            ),
          ),
          Expanded(
            child: lugaresFiltrados.isEmpty
                ? Center(
                    child: Text(
                      _filtro.isEmpty
                          ? 'No hay lugares registrados aún.'
                          : 'No se encontraron lugares con "$_filtro".',
                    ),
                  )
                : ListView.builder(
                    itemCount: lugaresFiltrados.length,
                    itemBuilder: (context, index) {
                      final lugar = lugaresFiltrados[index];
                      return ListTile(
                        title: Text(lugar.nombre),
                        subtitle: Text(lugar.descripcion),
                        trailing: FavoritoBoton(
                          // Al filtrar cambia el orden de la lista, la key evita
                          // que el estado del corazon se quede en otro lugar.
                          key: ValueKey(lugar.id),
                          favoritoInicial: lugar.favorito,
                          onToggle: () {
                            context.read<LugaresProvider>().toggleFavorito(lugar);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormularioScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
