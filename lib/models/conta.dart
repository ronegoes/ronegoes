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
