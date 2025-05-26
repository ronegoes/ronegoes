import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;


void main() {
  runApp(MyApp());
}

// Widget principal
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contas a Pagar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ContasApp(),
    );
  }
}

// Modelo de dados
class Conta {
  int? id;
  String nome;
  double valor;
  DateTime vencimento;
  bool paga;

  Conta({
    this.id,
    required this.nome,
    required this.valor,
    required this.vencimento,
    this.paga = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'valor': valor,
      'vencimento': vencimento.toIso8601String(),
      'paga': paga ? 1 : 0,
    };
  }

  factory Conta.fromMap(Map<String, dynamic> map) {
    return Conta(
      id: map['id'],
      nome: map['nome'],
      valor: map['valor'],
      vencimento: DateTime.parse(map['vencimento']),
      paga: map['paga'] == 1,
    );
  }
}

// SQLite Helper
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'contas.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            valor REAL,
            vencimento TEXT,
            paga INTEGER
          )
        ''');
      },
    );
    return _database!;
  }

  Future<int> insertConta(Conta conta) async {
    final db = await database;
    return await db.insert('contas', conta.toMap());
  }

  Future<List<Conta>> getContas() async {
    final db = await database;
    final maps = await db.query('contas');
    return maps.map((map) => Conta.fromMap(map)).toList();
  }

  Future<int> updateConta(Conta conta) async {
    final db = await database;
    return await db.update('contas', conta.toMap(), where: 'id = ?', whereArgs: [conta.id]);
  }

  Future<int> deleteConta(int id) async {
    final db = await database;
    return await db.delete('contas', where: 'id = ?', whereArgs: [id]);
  }
}

// Tela principal
class ContasApp extends StatefulWidget {
  @override
  _ContasAppState createState() => _ContasAppState();
}

class _ContasAppState extends State<ContasApp> {
  final List<Conta> contas = [];

  @override
  void initState() {
    super.initState();
    carregarContas();
  }

  Future<void> carregarContas() async {
    final lista = await DatabaseHelper.instance.getContas();
    setState(() {
      contas.clear();
      contas.addAll(lista);
    });
  }

  Future<void> adicionarOuEditarConta({Conta? contaExistente, int? index}) async {
    final resultado = await Navigator.push(
      context, // Corrigido aqui
      MaterialPageRoute(
        builder: (_) => CadastroContaPage(conta: contaExistente),
      ),
    );

    if (resultado != null && resultado is Conta) {
      if (index != null) {
        resultado.id = contaExistente!.id;
        await DatabaseHelper.instance.updateConta(resultado);
        setState(() => contas[index] = resultado);
      } else {
        final id = await DatabaseHelper.instance.insertConta(resultado);
        resultado.id = id;
        setState(() => contas.add(resultado));
      }
    }
  }


  void excluirConta(int index) {
    if (index < 0 || index >= contas.length) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Conta'),
        content: Text('Deseja realmente excluir esta conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final conta = contas[index];
              await DatabaseHelper.instance.deleteConta(conta.id!);
              setState(() => contas.removeAt(index));
              Navigator.pop(context);
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  Color corConta(Conta conta) {
    if (conta.paga) return Colors.green;
    if (conta.vencimento.isBefore(DateTime.now())) return Colors.red;
    return Colors.yellow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contas a Pagar')),
      body: Column(
        children: [
          Expanded(
            child: contas.isEmpty
                ? Center(child: Text('Nenhuma conta cadastrada.'))
                : ListView.builder(
              itemCount: contas.length,
              itemBuilder: (context, index) {
                final conta = contas[index];
                return Card(
                  color: corConta(conta),
                  child: ListTile(
                    title: Text(conta.nome),
                    subtitle: Text(
                      'R\$ ${conta.valor.toStringAsFixed(2)} - Vence em ${conta.vencimento.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: conta.paga ? Icon(Icons.check, color: Colors.white) : null,
                    onTap: () => adicionarOuEditarConta(contaExistente: conta, index: index),
                    onLongPress: () => excluirConta(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "vulgo:\nJhow Run\nDesenvolvedor: Roneii Gomes\nTel: (65) 9 8455-8815",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color:  Colors.grey[700]),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => adicionarOuEditarConta(),
        child: Icon(Icons.add),
      ),
    );
  }
}

// Tela de cadastro/edição
class CadastroContaPage extends StatefulWidget {
  final Conta? conta;

  CadastroContaPage({this.conta});

  @override
  _CadastroContaPageState createState() => _CadastroContaPageState();
}

class _CadastroContaPageState extends State<CadastroContaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime? _vencimento;
  bool _paga = false;

  @override
  void initState() {
    super.initState();
    if (widget.conta != null) {
      _nomeController.text = widget.conta!.nome;
      _valorController.text = widget.conta!.valor.toStringAsFixed(2);
      _vencimento = widget.conta!.vencimento;
      _paga = widget.conta!.paga;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conta != null ? 'Editar Conta' : 'Nova Conta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome da conta'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Valor inválido';
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(_vencimento == null
                      ? 'Selecione a data de vencimento'
                      : 'Vencimento: ${_vencimento!.toLocal().toString().split(' ')[0]}'),
                  Spacer(),
                  ElevatedButton(
                    child: Text('Selecionar Data'),
                    onPressed: () async {
                      final hoje = DateTime.now();
                      final dataSelecionada = await showDatePicker(
                        context: context,
                        initialDate: _vencimento ?? hoje,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (dataSelecionada != null) {
                        setState(() => _vencimento = dataSelecionada);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Conta paga?'),
                  Checkbox(
                      value: _paga, onChanged: (v) => setState(() => _paga = v ?? false)),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Salvar'),
                onPressed: () {
                  if (_formKey.currentState!.validate() && _vencimento != null) {
                    final novaConta = Conta(
                      nome: _nomeController.text,
                      valor: double.parse(_valorController.text.replaceAll(',', '.')),
                      vencimento: _vencimento!,
                      paga: _paga,
                    );
                    Navigator.pop(context, novaConta);
                  } else if (_vencimento == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selecione a data de vencimento')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
