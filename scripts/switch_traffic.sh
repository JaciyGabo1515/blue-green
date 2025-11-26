#!/bin/bash

# --- VARIABLES DE CONFIGURACIÓN ---
NEW_VERSION_IMAGE="app:v2.0-green"  # Nombre de la nueva imagen
OLD_PORT="8080"                     # Puerto del entorno Blue (actualmente activo)
NEW_PORT="8081"                     # Puerto del entorno Green (nuevo despliegue)
CONTAINER_NAME_NEW="app_green_new"  # Nombre del nuevo contenedor
NGINX_CONFIG_PATH="/etc/nginx/conf.d/blue-green.conf"
# --- FIN VARIABLES ---

echo "--- 1. DESPLIEGUE DE LA NUEVA VERSIÓN (GREEN) ---"
# Elimina cualquier contenedor antiguo que use el puerto nuevo, por seguridad
docker rm -f $CONTAINER_NAME_NEW 2>/dev/null

# Lanza la nueva versión de la aplicación en el puerto inactivo (8081)
docker run -d --name $CONTAINER_NAME_NEW -p $NEW_PORT:80 $NEW_VERSION_IMAGE

# Pausa breve para asegurar que el contenedor inicie y esté listo para servir
echo "Esperando 5 segundos para que el contenedor Green se inicialice..."
sleep 5
echo "Despliegue Green listo en puerto $NEW_PORT."

echo "--- 2. SWAP DE TRÁFICO EN NGINX (El Corazón Blue-Green) ---"
# Usa 'sed' para reemplazar la referencia del puerto antiguo por el nuevo en la configuración.
# CRÍTICO: El comando 'sed' debe coincidir exactamente con la línea en blue-green.conf
# En este caso, reemplaza '127.0.0.1:8080' por '127.0.0.1:8081'
sudo sed -i "s/127.0.0.1:$OLD_PORT/127.0.0.1:$NEW_PORT/g" $NGINX_CONFIG_PATH

echo "Verificando sintaxis de Nginx..."
sudo nginx -t

if [ $? -eq 0 ]; then
    # Recargar Nginx: ¡Esto es el switch instantáneo sin caídas!
    sudo nginx -s reload
    echo "✅ SWAP COMPLETO. El tráfico público ahora apunta al entorno GREEN."
else
    echo "❌ ERROR: Falló la verificación de Nginx. El tráfico NO FUE conmutado."
    exit 1
fi

echo "--- 3. CLEANUP (OPCIONAL) ---"
# Después de una conmutación exitosa, detén y elimina el contenedor BLUE antiguo
# docker stop app_blue
# docker rm app_blue

# NOTA: Para el próximo despliegue, necesitarás un script que invierta los puertos (8081 a 8080).