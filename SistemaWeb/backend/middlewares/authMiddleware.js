const authMiddleware = (req, res, next) => {
    const token = req.headers['authorization'];
    if (!token) {
      return res.status(403).json({ message: 'Token de autenticação é necessário' });
    }
    // Adicionar validação do token aqui
    next();
  };
  
  module.exports = authMiddleware;
  