Perfeito. Agora vamos para o Exercício 02 — V.0.0.2, em cima da nossa V.0.0.1.

Exercício 02 — Filtro por abas
Objetivo

Criar três filtros para as tarefas:

Todas
Pendentes
Concluídas

O contador do Exercício 01 continua funcionando e a persistência com SQLite também.

O que vamos alterar

Somente o:

lib/main.dart

Não precisamos alterar:

lib/models/tarefa.dart
lib/database/database_helper.dart
lib/providers/tarefa_provider.dart
lib/main.dart — V.0.0.2
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'providers/tarefa_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas (SQLite + Provider)'),
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

          List tarefasFiltradas;

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
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                          backgroundColor: _filtroSelecionado == 0
                              ? Colors.indigo
                              : Colors.grey.shade300,
                          foregroundColor: _filtroSelecionado == 0
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: Text('Todas ($totalTarefas)'),
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
                          backgroundColor: _filtroSelecionado == 1
                              ? Colors.indigo
                              : Colors.grey.shade300,
                          foregroundColor: _filtroSelecionado == 1
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: Text('Pendentes ($tarefasPendentes)'),
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
                          backgroundColor: _filtroSelecionado == 2
                              ? Colors.indigo
                              : Colors.grey.shade300,
                          foregroundColor: _filtroSelecionado == 2
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: Text('Concluídas ($tarefasConcluidas)'),
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
                          leading: Checkbox(
                            value: tarefa.concluida,
                            onChanged: (_) {
                              provider.alternarStatus(tarefa);
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
                              provider.removerTarefa(tarefa.id!);
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
O que foi acrescentado

Agora o HomeScreen precisa controlar qual filtro está selecionado, então ele passou de StatelessWidget para StatefulWidget:

class HomeScreen extends StatefulWidget

Foi criada a variável:

int _filtroSelecionado = 0;

Onde:

0 = Todas
1 = Pendentes
2 = Concluídas

Também calculamos:

final tarefasPendentes = provider.tarefas
    .where((tarefa) => !tarefa.concluida)
    .length;

E criamos a lista filtrada:

if (_filtroSelecionado == 1) {
  tarefasFiltradas = ...
} else if (_filtroSelecionado == 2) {
  tarefasFiltradas = ...
} else {
  tarefasFiltradas = provider.tarefas;
}
Como vai funcionar

Supondo:

5 tarefas
3 concluídas
2 pendentes

A interface mostra:

3 de 5 concluídas

[ Todas (5) ] [ Pendentes (2) ] [ Concluídas (3) ]

Ao clicar em Pendentes, aparecem somente as duas tarefas não concluídas.

Ao clicar em Concluídas, aparecem somente as três concluídas.

Ao clicar em Todas, todas voltam a aparecer.

E quando você marca/desmarca uma tarefa, os números dos botões também são atualizados pelo Consumer através do notifyListeners() do Provider.

Teste

Execute normalmente:

flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

Teste os três filtros e também marque/desmarque tarefas para conferir se os números são atualizados.

Agora nossa versão é V.0.0.2. O próximo exercício será o Exercício 03: editar a tarefa com onLongPress.

3

Perfeito. Agora vamos para o Exercício 03 — V.0.0.3, em cima da nossa V.0.0.2.

Exercício 03 — Editar tarefa com onLongPress
Objetivo

Permitir que o usuário edite a descrição de uma tarefa existente mantendo o clique normal para marcar/desmarcar e adicionando a edição através de um clique longo (onLongPress).

O que vamos alterar

Vamos precisar alterar:

lib/main.dart

E também o:

lib/providers/tarefa_provider.dart

porque agora o Provider precisa ter uma função para atualizar o título da tarefa no SQLite e na lista em memória.

1. Alterar lib/providers/tarefa_provider.dart

Adicione este método dentro da classe TarefaProvider:

Future<void> editarTarefa(Tarefa tarefa, String novoTitulo) async {
  if (novoTitulo.trim().isEmpty) return;

  final tarefaAtualizada = tarefa.copyWith(
    titulo: novoTitulo.trim(),
  );

  await DatabaseHelper.instance.update(tarefaAtualizada);

  final index = _tarefas.indexWhere((t) => t.id == tarefa.id);

  if (index != -1) {
    _tarefas[index] = tarefaAtualizada;
    notifyListeners();
  }
}

Então o seu tarefa_provider.dart completo fica:

import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';

class TarefaProvider extends ChangeNotifier {
  List<Tarefa> _tarefas = [];
  bool _isLoading = false;

  List<Tarefa> get tarefas => List.unmodifiable(_tarefas);
  bool get isLoading => _isLoading;

  Future<void> carregarTarefas() async {
    _isLoading = true;
    notifyListeners();

    _tarefas = await DatabaseHelper.instance.queryAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> adicionarTarefa(String titulo) async {
    if (titulo.trim().isEmpty) return;

    final novaTarefa = Tarefa(
      titulo: titulo.trim(),
    );

    final id = await DatabaseHelper.instance.insert(novaTarefa);

    _tarefas.insert(
      0,
      novaTarefa.copyWith(id: id),
    );

    notifyListeners();
  }

  Future<void> alternarStatus(Tarefa tarefa) async {
    final tarefaAtualizada = tarefa.copyWith(
      concluida: !tarefa.concluida,
    );

    await DatabaseHelper.instance.update(tarefaAtualizada);

    final index = _tarefas.indexWhere(
      (t) => t.id == tarefa.id,
    );

    if (index != -1) {
      _tarefas[index] = tarefaAtualizada;
      notifyListeners();
    }
  }

  Future<void> editarTarefa(
    Tarefa tarefa,
    String novoTitulo,
  ) async {
    if (novoTitulo.trim().isEmpty) return;

    final tarefaAtualizada = tarefa.copyWith(
      titulo: novoTitulo.trim(),
    );

    await DatabaseHelper.instance.update(tarefaAtualizada);

    final index = _tarefas.indexWhere(
      (t) => t.id == tarefa.id,
    );

    if (index != -1) {
      _tarefas[index] = tarefaAtualizada;
      notifyListeners();
    }
  }

  Future<void> removerTarefa(int id) async {
    await DatabaseHelper.instance.delete(id);

    _tarefas.removeWhere(
      (t) => t.id == id,
    );

    notifyListeners();
  }
}
2. Alterar lib/main.dart

Aqui vamos criar um diálogo para editar a tarefa.

O clique longo será feito diretamente no ListTile:

onLongPress: () {
  _exibirDialogEditarTarefa(context, tarefa);
},

Também vamos criar a função:

_exibirDialogEditarTarefa()

Ela abre um AlertDialog, coloca o título atual no TextField e permite salvar a alteração.

main.dart completo — V.0.0.3
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
Como funciona agora

O comportamento do item ficou:

Clique no Checkbox
        ↓
Conclui/desconclui a tarefa
Clique no ícone 🗑
        ↓
Exclui a tarefa
Clique longo na tarefa
        ↓
Abre "Editar Tarefa"
        ↓
Altera o texto
        ↓
Salvar
        ↓
Provider atualiza
        ↓
SQLite atualiza

A parte importante é que a edição não fica apenas na tela.

O método:

await DatabaseHelper.instance.update(tarefaAtualizada);

salva a alteração no SQLite.

Depois:

_tarefas[index] = tarefaAtualizada;
notifyListeners();

atualiza a lista do Provider e avisa o Consumer para reconstruir a interface.

Teste

Execute:

flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

Crie algumas tarefas, marque algumas como concluídas e teste os filtros.

Depois faça clique longo sobre uma tarefa, altere o texto e clique em Salvar.

Por fim, recarregue a aplicação. A descrição alterada deve continuar salva, confirmando que a alteração foi persistida no SQLite.

Agora estamos na V.0.0.3, com os três exercícios concluídos.

o readme no markdown
# Tarefas Provider App

Aplicativo desenvolvido em Flutter para praticar a integração entre **SQLite** e **Provider**, utilizando persistência local e gerenciamento de estado reativo.

O projeto permite cadastrar, listar, concluir, editar e excluir tarefas, mantendo os dados armazenados no banco de dados local.

---

## Versão Base — V.0.0

### Objetivo

Criar uma aplicação Flutter integrando três camadas principais:

- **Interface (UI)**: responsável pela apresentação das tarefas;
- **Provider**: responsável pelo gerenciamento do estado e das regras da aplicação;
- **SQLite**: responsável pela persistência dos dados.

A atividade trabalha principalmente:

- `Provider`;
- `ChangeNotifier`;
- `Consumer`;
- SQLite;
- operações CRUD;
- persistência local;
- operações assíncronas;
- atualização reativa da interface.

### O que foi desenvolvido

Foi criado o modelo `Tarefa`, contendo:

- `id`;
- `titulo`;
- `concluida`.

O modelo possui os métodos:

`toMap()`

Responsável por transformar a tarefa em um `Map` para armazenamento no banco.

`fromMap()`

Responsável por transformar os dados vindos do SQLite em um objeto `Tarefa`.

`copyWith()`

Utilizado para criar uma nova versão da tarefa mantendo os valores anteriores e alterando apenas os campos necessários.

Também foi criada a classe `DatabaseHelper`, responsável pela comunicação com o SQLite.

O banco utilizado é:

`tarefas.db`

A tabela criada é:

` tarefas `

com os campos:

- `id`;
- `titulo`;
- `concluida`.

O `DatabaseHelper` possui as operações:

- `insert()`;
- `queryAll()`;
- `update()`;
- `delete()`.

Para o gerenciamento do estado foi criado o `TarefaProvider`, que estende `ChangeNotifier`.

O Provider possui:

- `tarefas`;
- `isLoading`;
- `carregarTarefas()`;
- `adicionarTarefa()`;
- `alternarStatus()`;
- `removerTarefa()`.

Quando os dados são alterados, o método `notifyListeners()` atualiza automaticamente os widgets que utilizam o Provider.

Na inicialização da aplicação foi utilizado:

`ChangeNotifierProvider`

e as tarefas são carregadas automaticamente com:

`TarefaProvider()..carregarTarefas()`

Na interface principal foi utilizado:

`Consumer<TarefaProvider>`

A tela possui:

- indicador de carregamento;
- mensagem quando não existem tarefas;
- lista de tarefas;
- checkbox para concluir/desconcluir;
- botão para excluir;
- `FloatingActionButton` para adicionar tarefas;
- `AlertDialog` para cadastrar novas tarefas.

Como o projeto também é executado no Chrome, foi configurado o SQLite Web utilizando:

`sqflite_common_ffi_web`

e:

`databaseFactoryFfiWeb`.

### Resultado

A versão base apresenta uma aplicação de tarefas com SQLite integrado ao Provider.

As alterações realizadas na interface são sincronizadas com o banco de dados e os dados permanecem salvos após recarregar a aplicação.

---

## Exercício 01 — V.0.0.1

### Objetivo

Adicionar um contador no topo da tela indicando a proporção de tarefas concluídas.

O formato utilizado é:

`3 de 5 concluídas`

### O que mudou

Foi adicionada a contagem total de tarefas através de:

`provider.tarefas.length`

Também foi criada a contagem das tarefas concluídas utilizando `where()`:

`provider.tarefas.where((tarefa) => tarefa.concluida).length`

Esses valores são exibidos no topo da tela através de um `Text`.

Para permitir que o contador e a lista ocupem o espaço da tela corretamente, o `ListView.builder` passou a ficar dentro de um:

`Expanded`

O contador é atualizado automaticamente quando uma tarefa é marcada ou desmarcada, pois o Provider executa `notifyListeners()` após a alteração.

### Resultado

A aplicação passou a mostrar em tempo real quantas tarefas foram concluídas em relação ao total.

Exemplo:

`3 de 5 concluídas`

---

## Exercício 02 — V.0.0.2

### Objetivo

Implementar um filtro para visualizar as tarefas separadas em:

- **Todas**;
- **Pendentes**;
- **Concluídas**.

### O que mudou

O `HomeScreen` passou de `StatelessWidget` para `StatefulWidget` para armazenar o filtro atualmente selecionado.

Foi criada a variável:

`_filtroSelecionado`

Ela representa:

- `0` = Todas;
- `1` = Pendentes;
- `2` = Concluídas.

Também foram criadas listas filtradas utilizando `where()`.

Para as tarefas pendentes:

`provider.tarefas.where((tarefa) => !tarefa.concluida)`

Para as tarefas concluídas:

`provider.tarefas.where((tarefa) => tarefa.concluida)`

A interface recebeu três botões:

- `Todas`;
- `Pendentes`;
- `Concluídas`.

Cada botão apresenta também a quantidade correspondente.

O botão selecionado recebe destaque visual utilizando `Colors.indigo`.

Foi mantido o contador do Exercício 01:

`3 de 5 concluídas`

Também foi adicionada uma mensagem quando não existem tarefas no filtro selecionado:

`Nenhuma tarefa encontrada neste filtro!`

### Resultado

O usuário passou a conseguir alternar entre todas as tarefas, somente as pendentes ou somente as concluídas.

Os números exibidos nos filtros são atualizados automaticamente conforme o estado das tarefas muda.

---

## Exercício 03 — V.0.0.3

### Objetivo

Adicionar a possibilidade de editar a descrição de uma tarefa através de um clique longo (`onLongPress`).

### O que mudou

Foi adicionada uma nova função no `TarefaProvider`:

`editarTarefa()`

Essa função recebe a tarefa e o novo título.

Primeiro, o novo texto é validado para evitar salvar uma descrição vazia.

Depois é criada uma nova versão da tarefa utilizando:

`tarefa.copyWith(titulo: novoTitulo.trim())`

A alteração é salva no banco através de:

`DatabaseHelper.instance.update(tarefaAtualizada)`

Depois da atualização no banco, a tarefa também é atualizada na lista `_tarefas` do Provider.

Por fim, `notifyListeners()` informa à interface que o estado mudou.

Na interface foi criada a função:

`_exibirDialogEditarTarefa()`

Ela abre um `AlertDialog` contendo um `TextField` preenchido com a descrição atual da tarefa.

O `ListTile` passou a utilizar:

`onLongPress`

Assim, ao manter o clique sobre uma tarefa, o diálogo de edição é aberto.

O fluxo ficou:

`Clique longo → Editar Tarefa → Alterar descrição → Salvar → Atualizar Provider → Atualizar SQLite`

Todas as funcionalidades anteriores foram preservadas:

- contador de tarefas concluídas;
- filtros Todas/Pendentes/Concluídas;
- cadastro;
- conclusão/desconclusão;
- exclusão;
- persistência SQLite.

### Resultado

O usuário passou a conseguir editar a descrição de qualquer tarefa através de um clique longo.

A alteração é salva tanto no Provider quanto no SQLite, portanto permanece mesmo após recarregar a aplicação.

---

## Histórico de Versões

| Versão | Exercício | Alteração principal |
|---|---|---|
| **V.0.0** | Base | Integração entre SQLite e Provider com CRUD de tarefas |
| **V.0.0.1** | Exercício 01 | Contador de tarefas concluídas |
| **V.0.0.2** | Exercício 02 | Filtros Todas, Pendentes e Concluídas |
| **V.0.0.3** | Exercício 03 | Edição de tarefas com `onLongPress` |

---

## Arquitetura utilizada

O projeto foi organizado em três responsabilidades principais:

`UI`

Responsável pela interface e interação do usuário.

`Provider`

Responsável pelo gerenciamento do estado e pelas operações da aplicação.

`DatabaseHelper`

Responsável pela comunicação com o SQLite.

O fluxo principal de dados é:

`Tela → Provider → DatabaseHelper → SQLite`

Após a alteração:

`SQLite → Provider → notifyListeners() → Tela`

Essa separação evita que a interface execute diretamente comandos de banco de dados.

---

## Tecnologias utilizadas

- Flutter
- Dart
- Material Design
- Provider
- ChangeNotifier
- Consumer
- SQLite
- `sqflite`
- `path`
- `sqflite_common_ffi_web`

---

## Estrutura principal

tarefas_provider_app/
├── lib/
│   ├── main.dart
│   ├── database/
│   │   └── database_helper.dart
│   ├── models/
│   │   └── tarefa.dart
│   └── providers/
│       └── tarefa_provider.dart
├── web/
├── pubspec.yaml
└── ...

### Banco de Dados

Nome do banco:

tarefas.db

Tabela:

tarefas

Campos:

Campo	Tipo	Descrição
id	INTEGER	Identificador da tarefa
titulo	TEXT	Descrição da tarefa
concluida	INTEGER	Estado da tarefa

O campo concluida utiliza:

0 para pendente;
1 para concluída.
Funcionalidades finais
Cadastro

O usuário pode adicionar novas tarefas através do botão +.


### Execução

Para instalar as dependências:

#### flutter pub get

Para executar no Chrome:

#### flutter run -d chrome --web-port 8080

No Google Cloud Shell:

flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

Depois, no Web Preview, selecionar a porta 8080.
