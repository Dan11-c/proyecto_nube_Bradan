#!/bin/bash
dnf install -y nginx
systemctl enable --now nginx
cat > /usr/share/nginx/html/index.html <<EOF
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Librería Tinta - Servidor 2</title>
</head>
<body style="background:#fff3cd">
  <h1>Librería Tinta · SERVIDOR 2 (versión nueva)</h1>
  <p>Tu librería de barrio, ahora con club de lectura.</p>
  <h2>Horario</h2>
  <p>Lunes a viernes: 10:00 - 14:00 y 17:00 - 20:30<br>Sábados: 10:00 - 14:00</p>
  <h2>Dirección</h2>
  <p>Calle del Papel, 12 - 03690 San Vicente del Raspeig (Alicante)</p>
  <h2>Club de lectura</h2>
  <p>Jueves a las 19:00. Este mes: <strong>Fahrenheit 451</strong>, de Ray Bradbury.</p>
  <hr>
  <small>SERVIDOR 2 · Desplegado por Bradan Espla en el servidor $(hostname) el $(date '+%d/%m/%Y %H:%M')</small>
</body>
</html>
EOF
