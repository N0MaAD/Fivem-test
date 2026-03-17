// ========== MINIJEU ==========
const minigameEl = document.getElementById('minigame');
const cursorEl = document.getElementById('minigame-cursor');
const zoneEl = document.getElementById('minigame-zone');

let minigameActive = false;
let cursorPos = 0;
let cursorDir = 1;
let cursorSpeed = 0.4;
let zoneStart = 0;
let zoneSize = 20;
let animFrame = null;

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'startMinigame') {
        startMinigame(data.duration || 4000, data.zoneSize || 20);
    }

    if (data.action === 'openSellMenu') {
        openSellMenu(data.fish, data.level, data.xp);
    }
});

function startMinigame(duration, size) {
    minigameActive = true;
    zoneSize = Math.min(size, 60);
    cursorPos = 0;
    cursorDir = 1;
    cursorSpeed = 0.3 + Math.random() * 0.3;

    // Positionner la zone verte aléatoirement
    zoneStart = 10 + Math.random() * (80 - zoneSize);
    zoneEl.style.left = zoneStart + '%';
    zoneEl.style.width = zoneSize + '%';

    minigameEl.style.display = 'block';

    // Animer le curseur
    function animate() {
        if (!minigameActive) return;

        cursorPos += cursorDir * cursorSpeed;

        if (cursorPos >= 100) {
            cursorPos = 100;
            cursorDir = -1;
        } else if (cursorPos <= 0) {
            cursorPos = 0;
            cursorDir = 1;
        }

        cursorEl.style.left = cursorPos + '%';
        animFrame = requestAnimationFrame(animate);
    }

    animFrame = requestAnimationFrame(animate);

    // Timeout: échoue si pas de clic à temps
    setTimeout(function() {
        if (minigameActive) {
            endMinigame(false);
        }
    }, duration);
}

function endMinigame(success) {
    minigameActive = false;
    minigameEl.style.display = 'none';
    if (animFrame) cancelAnimationFrame(animFrame);

    fetch('https://esx_fishing/minigameResult', {
        method: 'POST',
        body: JSON.stringify({ success: success })
    });
}

// Écouter ESPACE pour le minijeu
document.addEventListener('keydown', function(e) {
    if (e.code === 'Space' && minigameActive) {
        e.preventDefault();
        const inZone = cursorPos >= zoneStart && cursorPos <= (zoneStart + zoneSize);
        endMinigame(inZone);
    }

    if (e.key === 'Escape') {
        closeSellMenu();
    }
});

// ========== MENU VENTE ==========
const sellMenuEl = document.getElementById('sell-menu');
const sellListEl = document.getElementById('sell-list');

function openSellMenu(fishList, level, xp) {
    document.getElementById('player-level').textContent = level || 1;
    document.getElementById('player-xp').textContent = xp || 0;

    if (!fishList || fishList.length === 0) {
        sellListEl.innerHTML = '<div class="empty-sell"><i class="fas fa-fish"></i>Aucun poisson à vendre</div>';
        document.getElementById('sell-all-btn').style.display = 'none';
    } else {
        let totalValue = 0;
        sellListEl.innerHTML = fishList.map(function(f) {
            totalValue += f.total;
            return `
                <div class="fish-row">
                    <div class="fish-icon"><i class="fas fa-fish"></i></div>
                    <div class="fish-info">
                        <div class="fish-name">${escapeHtml(f.label)}</div>
                        <div class="fish-detail">${f.amount}x &middot; $${f.price}/unité</div>
                    </div>
                    <div class="fish-total">$${formatMoney(f.total)}</div>
                    <button class="sell-btn" onclick="sellFish('${f.name}')">Vendre</button>
                </div>
            `;
        }).join('');

        document.getElementById('sell-all-btn').style.display = 'block';
        document.getElementById('sell-all-btn').innerHTML =
            '<i class="fas fa-cash-register"></i> Tout vendre ($' + formatMoney(totalValue) + ')';
    }

    sellMenuEl.style.display = 'block';
}

function closeSellMenu() {
    if (sellMenuEl.style.display !== 'none') {
        sellMenuEl.style.display = 'none';
        fetch('https://esx_fishing/closeSellMenu', { method: 'POST', body: '{}' });
    }
}

function sellFish(fishName) {
    fetch('https://esx_fishing/sellFish', {
        method: 'POST',
        body: JSON.stringify({ fishName: fishName })
    });
    closeSellMenu();
}

document.getElementById('close-sell').addEventListener('click', closeSellMenu);

document.getElementById('sell-all-btn').addEventListener('click', function() {
    fetch('https://esx_fishing/sellAll', { method: 'POST', body: '{}' });
    closeSellMenu();
});

// ========== UTILS ==========
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatMoney(n) {
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
}
