document.getElementById('loginForm').addEventListener('submit', async function (e) {
    e.preventDefault();
    
    const email = document.getElementById('email').value;
    const senha = document.getElementById('senha').value;
  
    const response = await fetch('http://localhost:5000/api/usuarios/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, senha }),
    });
  
    const data = await response.json();
    if (response.ok) {
      alert('Login bem-sucedido');
      // Redirecionar para o painel
    } else {
      alert(data.error || 'Erro ao fazer login');
    }
  });
  