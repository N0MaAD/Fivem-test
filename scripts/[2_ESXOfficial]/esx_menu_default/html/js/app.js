const container = document.getElementById('menu-container');
const titleEl = document.getElementById('menu-title');
const itemsEl = document.getElementById('menu-items');

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'openMenu') {
        titleEl.textContent = data.title || 'Menu';
        itemsEl.innerHTML = '';

        (data.elements || []).forEach(function(el, i) {
            const div = document.createElement('div');
            div.className = 'menu-item';
            div.textContent = el.label || el.name || 'Item ' + i;
            div.addEventListener('click', function() {
                fetch('https://esx_menu_default/menuSubmit', {
                    method: 'POST',
                    body: JSON.stringify({ index: i, value: el.value || el.name })
                });
            });
            itemsEl.appendChild(div);
        });

        container.style.display = 'block';
    }

    if (data.action === 'closeMenu') {
        container.style.display = 'none';
    }
});

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        fetch('https://esx_menu_default/menuCancel', {
            method: 'POST',
            body: JSON.stringify({})
        });
        container.style.display = 'none';
    }
});
