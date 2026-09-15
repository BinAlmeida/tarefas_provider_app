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

    final novaTarefa = Tarefa(titulo: titulo.trim());
    final id = await DatabaseHelper.instance.insert(novaTarefa);

    _tarefas.insert(0, novaTarefa.copyWith(id: id));
    notifyListeners();
  }

  Future<void> alternarStatus(Tarefa tarefa) async {
    final tarefaAtualizada = tarefa.copyWith(concluida: !tarefa.concluida);
    await DatabaseHelper.instance.update(tarefaAtualizada);

    final index = _tarefas.indexWhere((t) => t.id == tarefa.id);
    if (index != -1) {
      _tarefas[index] = tarefaAtualizada;
      notifyListeners();
    }
  }

  Future<void> removerTarefa(int id) async {
    await DatabaseHelper.instance.delete(id);
    _tarefas.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}