const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Configuração do banco de dados
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'sistemaWeb',
    password: '978564',
    port: 5432,
});

const app = express();
app.use(bodyParser.json());

// Middleware para verificar se o token JWT está presente e válido
function verificarToken(req, res, next) {
    const token = req.headers['authorization'];

    if (!token) {
        return res.status(403).send('Token não fornecido');
    }

    jwt.verify(token, 'secreto', (err, decoded) => {
        if (err) {
            return res.status(401).send('Token inválido');
        }
        req.usuarioId = decoded.id;  // Salva o ID do usuário no objeto da requisição
        next();
    });
}

// Rota de login
app.post('/login', async (req, res) => {
    const { email, senha } = req.body;

    try {
        // Verifica se o usuário existe no banco
        const result = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);

        if (result.rows.length === 0) {
            return res.status(401).send('Usuário não encontrado');
        }

        const usuario = result.rows[0];

        // Verifica a senha usando bcrypt
        const senhaCorreta = bcrypt.compareSync(senha, usuario.senha);

        if (senhaCorreta) {
            // Gera o token JWT
            const token = jwt.sign({ id: usuario.id }, 'secreto', { expiresIn: '1h' });
            res.json({ token });
        } else {
            res.status(401).send('Senha incorreta');
        }
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro interno do servidor');
    }
});

// Rota para cadastrar cliente
app.post('/clientes', async (req, res) => {
    const { nome, email, senha, endereco, telefone } = req.body;
    const hashedPassword = bcrypt.hashSync(senha, 10);

    try {
        await pool.query('INSERT INTO clientes (nome, email, senha, endereco, telefone) VALUES ($1, $2, $3, $4, $5)', 
        [nome, email, hashedPassword, endereco, telefone]);
        res.status(201).send('Cliente cadastrado');
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro ao cadastrar cliente');
    }
});

// Rota para cadastrar produto (somente para administradores)
app.post('/produtos', verificarToken, async (req, res) => {
    const { nome, descricao, preco, imagem, estoque } = req.body;

    try {
        await pool.query('INSERT INTO produtos (nome, descricao, preco, imagem, estoque) VALUES ($1, $2, $3, $4, $5)', 
        [nome, descricao, preco, imagem, estoque]);
        res.status(201).send('Produto cadastrado');
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro ao cadastrar produto');
    }
});

// Rota para registrar venda (necessário autenticação)
app.post('/vendas', verificarToken, async (req, res) => {
    const { cliente_id, total, itens } = req.body;

    try {
        const result = await pool.query('INSERT INTO vendas (cliente_id, total) VALUES ($1, $2) RETURNING id', 
        [cliente_id, total]);
        const venda_id = result.rows[0].id;

        for (let item of itens) {
            await pool.query('INSERT INTO itens_venda (venda_id, produto_id, quantidade, preco) VALUES ($1, $2, $3, $4)', 
            [venda_id, item.produto_id, item.quantidade, item.preco]);
            await pool.query('UPDATE produtos SET estoque = estoque - $1 WHERE id = $2', 
            [item.quantidade, item.produto_id]);
        }

        res.status(201).send('Venda registrada');
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro ao registrar venda');
    }
});

// Relatório de vendas (somente administradores)
app.get('/relatorio/vendas', verificarToken, async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM vendas');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro ao buscar relatórios de vendas');
    }
});

// Relatório de produtos (somente administradores)
app.get('/relatorio/produtos', verificarToken, async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM produtos');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro ao buscar relatórios de produtos');
    }
});

// Relatório de clientes (somente administradores)
app.get('/relatorio/clientes', verificarToken, async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM clientes');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro ao buscar relatórios de clientes');
    }
});

// Iniciar o servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
