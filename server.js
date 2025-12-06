const express = require('express');
const path = require('path');
const app = express();
const port = 3000; // El puerto interno ahora será 3000

// Servir archivos estáticos desde la carpeta 'app' (donde están tus HTML)
app.use(express.static('app'));

// Ruta principal: Envía el archivo index.html que hayamos copiado
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'app', 'index.html'));
});

// Ruta de prueba para Supertest (Endpoint 2)
app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'ok', version: 'blue-green' });
});

// Ruta de prueba de error (Endpoint 3)
app.get('/api/error', (req, res) => {
    res.status(404).json({ error: 'not found' });
});

// Solo iniciamos el servidor si no estamos en modo de prueba
if (require.main === module) {
    app.listen(port, () => {
        console.log(`App escuchando en puerto ${port}`);
    });
}

module.exports = app;