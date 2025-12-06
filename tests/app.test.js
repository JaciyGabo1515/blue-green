const request = require('supertest');
const app = require('../server');

describe('Pruebas de Integración (Requisito Remedial)', () => {
    
    // Prueba 1: Verificar que el sitio carga (HTML)
    it('Debe responder GET / con status 200 y ser HTML', async () => {
        const res = await request(app).get('/');
        expect(res.statusCode).toEqual(200);
        expect(res.headers['content-type']).toMatch(/html/);
    });

    // Prueba 2: Verificar endpoint de salud (JSON)
    it('Debe responder GET /api/health con JSON status ok', async () => {
        const res = await request(app).get('/api/health');
        expect(res.statusCode).toEqual(200);
        expect(res.body.status).toEqual('ok');
    });

    // Prueba 3: Verificar manejo de errores (404)
    it('Debe responder GET /ruta-inexistente con 404', async () => {
        const res = await request(app).get('/ruta-inexistente');
        expect(res.statusCode).toEqual(404);
    });
});