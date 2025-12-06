#!/bin/bash

# --- CONFIGURACIÓN ---
NGINX_CONF="/etc/nginx/conf.d/blue-green.conf"

# 1. DETECTAR EL COLOR ACTUAL
# Buscamos en el archivo de Nginx qué puerto está activo (8080 u 8081)
CURRENT_PORT=$(grep -oE '808[0-1]' $NGINX_CONF | head -1)

echo "--- ESTADO ACTUAL: El puerto activo es $CURRENT_PORT ---"

if [ "$CURRENT_PORT" == "8080" ]; then
    # Si es 8080 (Blue), nos toca desplegar GREEN (8081)
    echo "🔵 -> 🟢 Detectado BLUE. Iniciando despliegue de GREEN..."
    NEW_COLOR="green"
    NEW_PORT="8081"
    OLD_PORT="8080"
    HTML_FILE="app/index-green.html"
    CONTAINER_NAME="app_green"
else
    # Si es 8081 (Green), nos toca desplegar BLUE (8080)
    echo "🟢 -> 🔵 Detectado GREEN. Iniciando despliegue de BLUE..."
    NEW_COLOR="blue"
    NEW_PORT="8080"
    OLD_PORT="8081"
    HTML_FILE="app/index-blue.html"
    CONTAINER_NAME="app_blue"
fi

# 2. CONSTRUIR LA NUEVA IMAGEN
# Nota que usamos la variable $HTML_FILE que definimos arriba dinámicamente
echo "🏗️ Construyendo imagen para $NEW_COLOR..."
docker build --build-arg HTML_FILE=$HTML_FILE -t app:latest-$NEW_COLOR .

# 3. LIMPIEZA Y LANZAMIENTO
echo "🚀 Lanzando contenedor $NEW_COLOR en puerto $NEW_PORT..."
docker rm -f $CONTAINER_NAME 2>/dev/null
docker run -d --name $CONTAINER_NAME -p $NEW_PORT:3000 app:latest-$NEW_COLOR

# Esperar a que inicie
sleep 5

# 4. SWITCH DE TRÁFICO (EL CAMBIO REAL)
echo "🔀 Conmutando tráfico en Nginx..."
sudo sed -i "s/127.0.0.1:$OLD_PORT/127.0.0.1:$NEW_PORT/g" $NGINX_CONF

# 5. RECARGAR NGINX
echo "Verificando Nginx..."
sudo nginx -t
if [ $? -eq 0 ]; then
    sudo nginx -s reload
    echo "✅ DESPLIEGUE EXITOSO: Ahora estás en $NEW_COLOR ($NEW_PORT)"
else
    echo "❌ ERROR: Nginx falló. No se hizo el cambio."
    exit 1
fi