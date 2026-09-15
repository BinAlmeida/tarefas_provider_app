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
