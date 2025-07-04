// Exemplo de produtos no carrinho
const carrinho = [
    { nome: 'Produto 1', quantidade: 2, preco: 50.00 },
    { nome: 'Produto 2', quantidade: 1, preco: 100.00 },
    { nome: 'Produto 3', quantidade: 3, preco: 30.00 }
];

// Preenche os itens do carrinho na tela
function exibirCarrinho() {
    const itensCarrinho = document.getElementById('itens-carrinho');
    let totalCarrinho = 0;

    // Limpa a tabela de itens
    itensCarrinho.innerHTML = '';

    carrinho.forEach(item => {
        const totalItem = item.quantidade * item.preco;
        totalCarrinho += totalItem;

        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${item.nome}</td>
            <td><input type="number" value="${item.quantidade}" min="1" onchange="atualizarQuantidade(${carrinho.indexOf(item)}, this.value)"></td>
            <td>R$ ${item.preco.toFixed(2)}</td>
            <td>R$ ${totalItem.toFixed(2)}</td>
            <td><button onclick="removerItem(${carrinho.indexOf(item)})">Remover</button></td>
        `;
        itensCarrinho.appendChild(row);
    });

    // Atualiza o total do carrinho
    document.getElementById('total').innerText = `R$ ${totalCarrinho.toFixed(2)}`;
}

// Atualiza a quantidade de um item
function atualizarQuantidade(index, novaQuantidade) {
    if (novaQuantidade > 0) {
        carrinho[index].quantidade = parseInt(novaQuantidade);
        exibirCarrinho();
    }
}

// Remove um item do carrinho
function removerItem(index) {
    carrinho.splice(index, 1);
    exibirCarrinho();
}

// Função para finalizar a compra
document.getElementById('form-pagamento').addEventListener('submit', function(e) {
    e.preventDefault();

    const formaPagamento = document.querySelector('input[name="pagamento"]:checked');
    if (!formaPagamento) {
        alert('Por favor, escolha uma forma de pagamento!');
        return;
    }

    alert(`Compra finalizada com sucesso! Pagamento via ${formaPagamento.value}.`);
});

// Inicializa a tela com os itens do carrinho
exibirCarrinho();
