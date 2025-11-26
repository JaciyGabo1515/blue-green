# Usa una imagen base de Nginx muy ligera (Alpine)
FROM nginx:alpine

# Argumento para pasar el nombre del archivo HTML que queremos usar
ARG HTML_FILE=index-blue.html

# Copia el archivo HTML deseado al directorio de servicio por defecto de Nginx
COPY $HTML_FILE /usr/share/nginx/html/index.html

# El puerto 80 es el puerto interno del contenedor Nginx
EXPOSE 80

# Comando de inicio por defecto de Nginx (ya viene de la imagen base)
CMD ["nginx", "-g", "daemon off;"]