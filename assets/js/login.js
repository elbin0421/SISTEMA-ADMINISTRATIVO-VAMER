// Redirigir si ya tiene sesión activa
    const tk = document.cookie.split(';').find(c => c.trim().startsWith('sm_token='));
    if (tk) {
      fetch('controllers/AuthController.php?action=verificar', { credentials: 'include' })
        .then(r => r.json())
        .then(d => { if (d.ok) window.location.href = 'dashboard.php'; });
    }

    document.getElementById('loginForm').addEventListener('submit', async function(e) {
      e.preventDefault();
      const btn = document.getElementById('btnLogin');
      const err = document.getElementById('errorMsg');
      btn.disabled    = true;
      btn.textContent = 'Ingresando...';
      err.style.display = 'none';

      try {
        const res  = await fetch('controllers/AuthController.php?action=login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          credentials: 'include',
          body: JSON.stringify({
            usuario:  document.getElementById('usuario').value.trim(),
            password: document.getElementById('password').value
          })
        });
        const data = await res.json();
        if (data.ok) {
          localStorage.setItem('sm_nombre', data.nombre);
          localStorage.setItem('sm_rol',    data.rol);
          localStorage.setItem('sm_token',  data.token);
          window.location.href = 'dashboard.php';
        } else {
          err.textContent   = data.error || 'Error al ingresar.';
          err.style.display = 'block';
          btn.disabled      = false;
          btn.textContent   = 'Ingresar';
        }
      } catch(ex) {
        err.textContent   = 'No se pudo conectar al servidor.';
        err.style.display = 'block';
        btn.disabled      = false;
        btn.textContent   = 'Ingresar';
      }
    });
