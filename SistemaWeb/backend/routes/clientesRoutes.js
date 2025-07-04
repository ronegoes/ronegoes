const express = require('express');
const router = express.Router();
const clienteController = require('../controllers/clienteController');

router.post('/', clienteController.criar);
router.get('/', clienteController.listar);

module.exports = router;
