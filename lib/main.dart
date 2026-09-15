import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'providers/tarefa_provider.dart';
import 'models/tarefa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => TarefaProvider()..carregarTarefas(),
      child: const TarefasApp(),
    ),
  );
}

class TarefasApp extends StatelessWidget {
  const TarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarefas com Provider & SQLite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _filtroSelecionado = 0;

  void _exibirDialogNovaTarefa(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Tarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Descrição da tarefa',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<TarefaProvider>(
                  context,
                  listen: false,
                ).adicionarTarefa(controller.text);

                Navigator.pop(ctx);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _exibirDialogEditarTarefa(
    BuildContext context,
    Tarefa tarefa,
  ) {
    final controller = TextEditingController(
      text: tarefa.titulo,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Tarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Descrição da tarefa',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<TarefaProvider>(
                  context,
                  listen: false,
                ).editarTarefa(
                  tarefa,
                  controller.text,
                );

                Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Tarefas (SQLite + Provider)',
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<TarefaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final totalTarefas = provider.tarefas.length;

          final tarefasConcluidas = provider.tarefas
              .where((tarefa) => tarefa.concluida)
              .length;

          final tarefasPendentes = provider.tarefas
              .where((tarefa) => !tarefa.concluida)
              .length;

          List<Tarefa> tarefasFiltradas;

          if (_filtroSelecionado == 1) {
            tarefasFiltradas = provider.tarefas
                .where((tarefa) => !tarefa.concluida)
                .toList();
          } else if (_filtroSelecionado == 2) {
            tarefasFiltradas = provider.tarefas
                .where((tarefa) => tarefa.concluida)
                .toList();
          } else {
            tarefasFiltradas = provider.tarefas;
          }

          if (provider.tarefas.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma tarefa cadastrada ainda!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$tarefasConcluidas de $totalTarefas concluídas',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _filtroSelecionado = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _filtroSelecionado == 0
                                  ? Colors.indigo
                                  : Colors.grey.shade300,
                          foregroundColor:
                              _filtroSelecionado == 0
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        child: Text(
                          'Todas ($totalTarefas)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _filtroSelecionado = 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _filtroSelecionado == 1
                                  ? Colors.indigo
                                  : Colors.grey.shade300,
                          foregroundColor:
                              _filtroSelecionado == 1
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        child: Text(
                          'Pendentes ($tarefasPendentes)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _filtroSelecionado = 2;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _filtroSelecionado == 2
                                  ? Colors.indigo
                                  : Colors.grey.shade300,
                          foregroundColor:
                              _filtroSelecionado == 2
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        child: Text(
                          'Concluídas ($tarefasConcluidas)',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              if (tarefasFiltradas.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Nenhuma tarefa encontrada neste filtro!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: tarefasFiltradas.length,
                    itemBuilder: (ctx, index) {
                      final tarefa = tarefasFiltradas[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          onLongPress: () {
                            _exibirDialogEditarTarefa(
                              context,
                              tarefa,
                            );
                          },
                          leading: Checkbox(
                            value: tarefa.concluida,
                            onChanged: (_) {
                              provider.alternarStatus(
                                tarefa,
                              );
                            },
                          ),
                          title: Text(
                            tarefa.titulo,
                            style: TextStyle(
                              decoration: tarefa.concluida
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: tarefa.concluida
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              provider.removerTarefa(
                                tarefa.id!,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _exibirDialogNovaTarefa(context),
        backgroundColor: Colors.indigo,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}