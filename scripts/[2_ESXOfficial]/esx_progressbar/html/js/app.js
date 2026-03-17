const container = document.getElementById('progress-container');
const label = document.getElementById('progress-label');
const fill = document.getElementById('progress-bar-fill');

let timer = null;

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'start') {
        label.textContent = data.label || '';
        fill.style.width = '0%';
        container.style.display = 'block';

        const duration = data.duration || 3000;
        const interval = 50;
        let elapsed = 0;

        clearInterval(timer);
        timer = setInterval(function() {
            elapsed += interval;
            const pct = Math.min((elapsed / duration) * 100, 100);
            fill.style.width = pct + '%';

            if (elapsed >= duration) {
                clearInterval(timer);
                container.style.display = 'none';
            }
        }, interval);
    }

    if (data.action === 'stop') {
        clearInterval(timer);
        container.style.display = 'none';
    }
});
