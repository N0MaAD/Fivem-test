const container = document.getElementById('notification-container');

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'notify') {
        const notif = document.createElement('div');
        notif.className = 'notification ' + (data.type || 'info');
        notif.textContent = data.message || '';

        container.appendChild(notif);

        const duration = data.duration || 5000;

        setTimeout(function() {
            notif.classList.add('fadeOut');
            setTimeout(function() {
                notif.remove();
            }, 300);
        }, duration);
    }
});
