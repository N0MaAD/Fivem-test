// ========== STATE ==========
let myPhoneNumber = 'N/A';
let currentContacts = [];
let currentMessages = [];

// ========== DOM ==========
const phone = document.getElementById('phone');
const pages = document.querySelectorAll('.page');

// ========== HORLOGE ==========
function updateClock() {
    const now = new Date();
    const h = String(now.getHours()).padStart(2, '0');
    const m = String(now.getMinutes()).padStart(2, '0');
    document.getElementById('clock').textContent = h + ':' + m;
}
setInterval(updateClock, 10000);
updateClock();

// ========== NAVIGATION ==========
function showPage(pageId) {
    pages.forEach(p => p.classList.remove('active'));
    const target = document.getElementById('page-' + pageId);
    if (target) target.classList.add('active');
}

// App icons
document.querySelectorAll('.app-icon[data-page]').forEach(icon => {
    icon.addEventListener('click', () => showPage(icon.dataset.page));
});

// Back buttons
document.querySelectorAll('.back-btn[data-page]').forEach(btn => {
    btn.addEventListener('click', () => showPage(btn.dataset.page));
});

// Navbar
document.querySelectorAll('.nav-btn[data-page]').forEach(btn => {
    btn.addEventListener('click', () => showPage(btn.dataset.page));
});

// ========== NUI MESSAGES ==========
window.addEventListener('message', function(event) {
    const data = event.data;

    switch(data.action) {
        case 'openPhone':
            phone.style.display = 'flex';
            myPhoneNumber = data.phoneNumber || 'N/A';
            document.getElementById('my-number').textContent = myPhoneNumber;
            document.getElementById('settings-number').textContent = myPhoneNumber;
            showPage('home');
            break;

        case 'closePhone':
            phone.style.display = 'none';
            closeAllModals();
            break;

        case 'loadContacts':
            currentContacts = data.contacts || [];
            renderContacts();
            break;

        case 'loadMessages':
            currentMessages = data.messages || [];
            renderMessages();
            break;

        case 'newMessage':
            renderMessages();
            break;

        case 'loadBank':
            renderBank(data.bank);
            break;

        case 'loadCallHistory':
            renderCallHistory(data.calls || []);
            break;

        case 'loadTwitter':
            renderTwitter(data.tweets || []);
            break;

        case 'incomingCall':
            showIncomingCall(data.callerName, data.callerNumber);
            break;

        case 'callAnswered':
            showCallActive();
            break;

        case 'callEnded':
            hideCallOverlay();
            break;
    }
});

// ========== CONTACTS ==========
function renderContacts() {
    const list = document.getElementById('contacts-list');

    if (currentContacts.length === 0) {
        list.innerHTML = '<div class="empty-state"><i class="fas fa-address-book"></i>Aucun contact</div>';
        return;
    }

    list.innerHTML = currentContacts.map(c => `
        <div class="contact-item">
            <div class="contact-avatar">${(c.name || '?')[0].toUpperCase()}</div>
            <div class="contact-info">
                <div class="contact-name">${escapeHtml(c.name)}</div>
                <div class="contact-number">${escapeHtml(c.number)}</div>
            </div>
            <div class="contact-actions">
                <button class="contact-action-btn call" onclick="callContact('${escapeAttr(c.number)}')" title="Appeler">
                    <i class="fas fa-phone"></i>
                </button>
                <button class="contact-action-btn sms" onclick="smsContact('${escapeAttr(c.number)}')" title="Message">
                    <i class="fas fa-comment"></i>
                </button>
                <button class="contact-action-btn delete" onclick="deleteContact(${c.id})" title="Supprimer">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        </div>
    `).join('');
}

function callContact(number) {
    fetch('https://esx_phone/callNumber', { method: 'POST', body: JSON.stringify({ number: number }) });
    showOutgoingCall(number);
}

function smsContact(number) {
    showPage('messages');
    document.getElementById('new-message-modal').style.display = 'flex';
    document.getElementById('msg-target').value = number;
    document.getElementById('msg-content').focus();
}

function deleteContact(id) {
    fetch('https://esx_phone/deleteContact', { method: 'POST', body: JSON.stringify({ id: id }) });
}

// Add contact modal
document.getElementById('add-contact-btn').addEventListener('click', () => {
    document.getElementById('add-contact-modal').style.display = 'flex';
    document.getElementById('new-contact-name').value = '';
    document.getElementById('new-contact-number').value = '';
    document.getElementById('new-contact-name').focus();
});

document.getElementById('cancel-add-contact').addEventListener('click', () => {
    document.getElementById('add-contact-modal').style.display = 'none';
});

document.getElementById('confirm-add-contact').addEventListener('click', () => {
    const name = document.getElementById('new-contact-name').value.trim();
    const number = document.getElementById('new-contact-number').value.trim();

    if (!name || !number) return;

    fetch('https://esx_phone/addContact', {
        method: 'POST',
        body: JSON.stringify({ name: name, number: number })
    });

    document.getElementById('add-contact-modal').style.display = 'none';
});

// ========== MESSAGES ==========
function renderMessages() {
    const list = document.getElementById('messages-list');

    if (currentMessages.length === 0) {
        list.innerHTML = '<div class="empty-state"><i class="fas fa-comment-dots"></i>Aucun message</div>';
        return;
    }

    list.innerHTML = currentMessages.map(m => {
        const isMine = m.sender === myPhoneNumber;
        const contactName = getContactName(isMine ? m.receiver : m.sender);
        const displayName = contactName || (isMine ? m.receiver : m.sender);

        return `
        <div class="message-item">
            <button class="message-delete-btn" onclick="deleteMessage(${m.id})"><i class="fas fa-times"></i></button>
            <div class="message-sender">${isMine ? 'Moi → ' + escapeHtml(displayName) : escapeHtml(displayName)}</div>
            <div class="message-text">${escapeHtml(m.message)}</div>
            <div class="message-time">${formatDate(m.created_at)}</div>
        </div>
        `;
    }).join('');
}

function deleteMessage(id) {
    fetch('https://esx_phone/deleteMessage', { method: 'POST', body: JSON.stringify({ id: id }) });
}

function getContactName(number) {
    const contact = currentContacts.find(c => c.number === number);
    return contact ? contact.name : null;
}

// New message modal
document.getElementById('new-message-btn').addEventListener('click', () => {
    document.getElementById('new-message-modal').style.display = 'flex';
    document.getElementById('msg-target').value = '';
    document.getElementById('msg-content').value = '';
    document.getElementById('msg-target').focus();
});

document.getElementById('cancel-new-msg').addEventListener('click', () => {
    document.getElementById('new-message-modal').style.display = 'none';
});

document.getElementById('confirm-new-msg').addEventListener('click', () => {
    const target = document.getElementById('msg-target').value.trim();
    const message = document.getElementById('msg-content').value.trim();

    if (!target || !message) return;

    fetch('https://esx_phone/sendMessage', {
        method: 'POST',
        body: JSON.stringify({ target: target, message: message })
    });

    document.getElementById('new-message-modal').style.display = 'none';
});

// ========== DIALER ==========
document.querySelectorAll('.dial-key').forEach(key => {
    key.addEventListener('click', () => {
        const input = document.getElementById('dial-number');
        input.value += key.dataset.key;
    });
});

document.getElementById('make-call-btn').addEventListener('click', () => {
    const number = document.getElementById('dial-number').value.trim();
    if (!number) return;

    fetch('https://esx_phone/callNumber', { method: 'POST', body: JSON.stringify({ number: number }) });
    showOutgoingCall(number);
    document.getElementById('dial-number').value = '';
});

// ========== CALL HISTORY ==========
function renderCallHistory(calls) {
    const list = document.getElementById('call-history');

    if (calls.length === 0) {
        list.innerHTML = '<div class="empty-state"><i class="fas fa-phone"></i>Aucun appel</div>';
        return;
    }

    list.innerHTML = calls.map(c => {
        const isCaller = c.caller === myPhoneNumber;
        const otherNumber = isCaller ? c.receiver : c.caller;
        const contactName = getContactName(otherNumber);
        const iconClass = c.status === 'answered' ? 'answered' : 'missed';
        const icon = c.status === 'answered'
            ? (isCaller ? 'fa-phone-arrow-up-right' : 'fa-phone-arrow-down-left')
            : 'fa-phone-missed';

        return `
        <div class="call-item">
            <div class="call-icon ${iconClass}"><i class="fas ${icon.startsWith('fa-phone-arrow') ? 'fa-phone' : 'fa-phone-slash'}"></i></div>
            <div class="call-info-text">
                <div class="call-number-text">${contactName ? escapeHtml(contactName) : escapeHtml(otherNumber)}</div>
                <div class="call-date-text">${formatDate(c.created_at)}</div>
            </div>
            <span class="call-status-badge">${c.status === 'answered' ? 'Répondu' : 'Manqué'}</span>
        </div>
        `;
    }).join('');
}

// ========== BANQUE ==========
function renderBank(bank) {
    if (!bank) return;
    document.getElementById('bank-amount').textContent = '$' + formatMoney(bank.bank || 0);
    document.getElementById('cash-amount').textContent = '$' + formatMoney(bank.money || 0);
    document.getElementById('dirty-amount').textContent = '$' + formatMoney(bank.black_money || 0);
}

// ========== TWITTER ==========
function renderTwitter(tweets) {
    const feed = document.getElementById('twitter-feed');

    if (tweets.length === 0) {
        feed.innerHTML = '<div class="empty-state"><i class="fab fa-twitter"></i>Aucun tweet</div>';
        return;
    }

    feed.innerHTML = tweets.map(t => `
        <div class="tweet-item">
            <div class="tweet-author">@${escapeHtml(t.author)}</div>
            <div class="tweet-text">${escapeHtml(t.message)}</div>
            <div class="tweet-time">${formatDate(t.created_at)}</div>
        </div>
    `).join('');
}

// Load twitter on page open
document.querySelector('.app-icon[data-page="twitter"]').addEventListener('click', () => {
    fetch('https://esx_phone/requestTwitter', { method: 'POST', body: '{}' });
});

document.getElementById('post-tweet-btn').addEventListener('click', () => {
    const input = document.getElementById('tweet-input');
    const msg = input.value.trim();
    if (!msg) return;

    fetch('https://esx_phone/postTweet', { method: 'POST', body: JSON.stringify({ message: msg }) });
    input.value = '';

    setTimeout(() => {
        fetch('https://esx_phone/requestTwitter', { method: 'POST', body: '{}' });
    }, 500);
});

// ========== CALL OVERLAY ==========
function showIncomingCall(name, number) {
    document.getElementById('call-name').textContent = name || 'Inconnu';
    document.getElementById('call-number-display').textContent = number || '';
    document.getElementById('call-status').textContent = 'Appel entrant...';
    document.getElementById('call-overlay').style.display = 'flex';

    document.querySelector('.call-actions').style.display = 'flex';
    document.getElementById('hangup-btn').style.display = 'none';
}

function showOutgoingCall(number) {
    const contactName = getContactName(number);
    document.getElementById('call-name').textContent = contactName || number;
    document.getElementById('call-number-display').textContent = number;
    document.getElementById('call-status').textContent = 'Appel en cours...';
    document.getElementById('call-overlay').style.display = 'flex';

    document.querySelector('.call-actions').style.display = 'none';
    document.getElementById('hangup-btn').style.display = 'flex';
}

function showCallActive() {
    document.getElementById('call-status').textContent = 'En communication';
    document.querySelector('.call-actions').style.display = 'none';
    document.getElementById('hangup-btn').style.display = 'flex';
}

function hideCallOverlay() {
    document.getElementById('call-overlay').style.display = 'none';
}

document.getElementById('answer-call-btn').addEventListener('click', () => {
    fetch('https://esx_phone/answerCall', { method: 'POST', body: '{}' });
});

document.getElementById('decline-call-btn').addEventListener('click', () => {
    fetch('https://esx_phone/declineCall', { method: 'POST', body: '{}' });
});

document.getElementById('hangup-btn').addEventListener('click', () => {
    fetch('https://esx_phone/hangUp', { method: 'POST', body: '{}' });
});

// ========== CLOSE PHONE (ESC) ==========
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        fetch('https://esx_phone/closePhone', { method: 'POST', body: '{}' });
    }
});

// ========== UTILS ==========
function closeAllModals() {
    document.querySelectorAll('.modal').forEach(m => m.style.display = 'none');
    hideCallOverlay();
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function escapeAttr(text) {
    if (!text) return '';
    return text.replace(/'/g, "\\'").replace(/"/g, '\\"');
}

function formatMoney(n) {
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
}

function formatDate(dateStr) {
    if (!dateStr) return '';
    try {
        const d = new Date(dateStr);
        const day = String(d.getDate()).padStart(2, '0');
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const h = String(d.getHours()).padStart(2, '0');
        const m = String(d.getMinutes()).padStart(2, '0');
        return day + '/' + month + ' ' + h + ':' + m;
    } catch(e) {
        return dateStr;
    }
}
