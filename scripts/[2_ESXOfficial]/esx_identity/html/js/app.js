const form = document.getElementById('identity-form');
const submitBtn = document.getElementById('submit-btn');

window.addEventListener('message', function(event) {
    if (event.data.action === 'openForm') {
        form.style.display = 'block';
    }
    if (event.data.action === 'closeForm') {
        form.style.display = 'none';
    }
});

submitBtn.addEventListener('click', function() {
    const data = {
        firstname:   document.getElementById('firstname').value,
        lastname:    document.getElementById('lastname').value,
        dateofbirth: document.getElementById('dateofbirth').value,
        sex:         document.getElementById('sex').value,
    };

    if (!data.firstname || !data.lastname || !data.dateofbirth) {
        alert('Veuillez remplir tous les champs.');
        return;
    }

    fetch('https://esx_identity/registerSubmit', {
        method: 'POST',
        body: JSON.stringify(data)
    });
});
