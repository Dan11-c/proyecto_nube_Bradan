#!/bin/bash
dnf install -y nginx
systemctl enable --now nginx
cat > /usr/share/nginx/html/index.html <<EOF
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Librería Tinta</title>
</head>
<body>
  <h1>Librería Tinta</h1>
  <p>Tu librería de barrio.</p>
  <h2>Horario</h2>
  <p>Lunes a viernes: 10:00 - 14:00 y 17:00 - 20:30<br>Sábados: 10:00 - 14:00</p>
  <h2>Dirección</h2>
  <p>Calle del Papel, 12 - 03690 San Vicente del Raspeig (Alicante)</p>
  <h2>Recomendación del mes</h2>
  <p><strong>El nombre del viento</strong>, de Patrick Rothfuss.</p>
  <hr>
  <small>Desplegado por Bradan Espla en el servidor $(hostname) el $(date '+%d/%m/%Y %H:%M')</small>
</body>
</html>
EOF
