const clienteModel = require('../models/clienteModel');

const clienteController = {
  criar: async (req, res) => {
    try {
      const cliente = await clienteModel.criar(req.body);
      res.status(201).json(cliente);
    } catch (error) {
      res.status(500).json({ error: 'Erro ao criar cliente' });
    }
  },

  listar: async (req, res) => {
    try {
      const clientes = await clienteModel.listar();
      res.status(200).json(clientes);
    } catch (error) {
      res.status(500).json({ error: 'Erro ao listar clientes' });
    }
  }
};

module.exports = clienteController;
