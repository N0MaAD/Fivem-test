const healthFill = document.getElementById('health-fill');
const armourFill = document.getElementById('armour-fill');
const moneyValue = document.getElementById('money-value');
const bankValue = document.getElementById('bank-value');

function formatMoney(n) {
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'updateHud') {
        healthFill.style.width = Math.min(data.health, 100) + '%';
        armourFill.style.width = Math.min(data.armour, 100) + '%';
        moneyValue.textContent = formatMoney(data.money || 0);
        bankValue.textContent = formatMoney(data.bank || 0);
    }
});
