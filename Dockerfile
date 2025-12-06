# Usamos Node en vez de Nginx
FROM node:alpine

# Creamos directorio de trabajo
WORKDIR /usr/src/app

# Copiamos archivos de dependencias
COPY package*.json ./

# Instalamos dependencias
RUN npm install

# Copiamos el código del servidor
COPY server.js .

# --- MAGIA BLUE-GREEN ---
# Recibimos el argumento de cuál HTML usar (igual que antes)
ARG HTML_FILE=app/index-blue.html

# Copiamos ESE archivo específico y lo renombramos a index.html dentro de la carpeta 'app'
# Nota: Creamos la carpeta 'app' dentro del contenedor primero
RUN mkdir app
COPY ${HTML_FILE} app/index.html

# Node usa el puerto 3000 por defecto
EXPOSE 3000

# Comando para iniciar
CMD ["node", "server.js"]