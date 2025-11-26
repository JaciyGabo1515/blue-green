#!/bin/bash

# --- VARIABLES ---
ACTIVE_PORT="8081"   # Puerto actual (Green)
TARGET_PORT="8080"   # Puerto destino (Blue)
NGINX_CONFIG_PATH="/etc/nginx/conf.d/blue-green.conf"

echo "--- INICIANDO ROLLBACK A BLUE ---"

# 1. Asegurarnos que el contenedor BLUE esté corriendo
# Si lo detuviste, esto intentará iniciarlo. Si ya corre, no pasa nada.
docker start app_blue 2>/dev/null
echo "Asegurando que contenedor Blue esté activo..."

# 2. Revertir configuración de Nginx
# Buscamos '127.0.0.1:8081' y lo cambiamos por '127.0.0.1:8080'
sudo sed -i "s/127.0.0.1:$ACTIVE_PORT/127.0.0.1:$TARGET_PORT/g" $NGINX_CONFIG_PATH

echo "Verificando sintaxis de Nginx..."
sudo nginx -t

if [ $? -eq 0 ]; then
    # Recargar Nginx
    sudo nginx -s reload
    echo "✅ ROLLBACK COMPLETO. Estás viendo el entorno BLUE (Puerto 8080)."
else
    echo "❌ ERROR: Falló la verificación de Nginx. No se hizo el cambio."
    exit 1
fi