const { Client } = require('pg');

const clienteModel = {
  criar: async (dados) => {
    const query = 'INSERT INTO clientes(nome, email, telefone) VALUES($1, $2, $3) RETURNING *';
    const values = [dados.nome, dados.email, dados.telefone];
    const res = await client.query(query, values);
    return res.rows[0];
  },

  listar: async () => {
    const res = await client.query('SELECT * FROM clientes');
    return res.rows;
  }
};

module.exports = clienteModel;
