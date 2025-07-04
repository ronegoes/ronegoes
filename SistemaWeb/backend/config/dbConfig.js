const { Client } = require('pg');

const dbConfig = () => {
  const client = new Client({
    user: 'postgres',
    host: 'localhost',
    database: 'sistemaWeb',
    password: '978564',
    port: 5432,
  });

  client.connect((err) => {
    if (err) {
      console.error('Erro ao conectar ao banco de dados', err);
      return;
    }
    console.log('Banco de dados conectado com sucesso!');
  });
};

module.exports = dbConfig;
