window.addEventListener('message', function(event) {
    switch(event.data.type) {
        case 'update':
            document.getElementById('level').textContent = event.data.level;
            document.getElementById('exp').textContent = event.data.exp;
            document.getElementById('max-exp').textContent = event.data.maxExp;
            
            if (event.data.level >= 5) { // Aqui ajustamos para o nível máximo 5
                document.getElementById('exp').textContent = 'MAX';
                document.getElementById('max-exp').textContent = 'MAX';
                document.getElementById('exp-fill').style.width = '100%'; // Preenche a barra de experiência completamente
            } else {
                const expPercentage = (event.data.exp / event.data.maxExp) * 100;
                document.getElementById('exp-fill').style.width = expPercentage + '%';
                document.getElementById('exp').textContent = event.data.exp;
                document.getElementById('max-exp').textContent = event.data.maxExp;
            }
            break;
        case 'show':
            document.getElementById('miner-ui').style.display = 'block'; // Mostra o painel quando necessário
            break;
        case 'hide':
            document.getElementById('miner-ui').style.display = 'none'; // Esconde o painel quando necessário
            break;
        case 'showCancelButton':
            document.getElementById('cancel-mining').style.display = 'block';
            break;
        case 'hideCancelButton':
            document.getElementById('cancel-mining').style.display = 'none';
            break;
    }
});

document.getElementById('cancel-mining').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/cancelMining`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(resp => console.log(resp));
});
