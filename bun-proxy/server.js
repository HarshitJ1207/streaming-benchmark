const { Hono } = require('hono');

const app = new Hono();

const FILE_SERVER = 'http://localhost:8080';

app.get('/small', async (c) => {
  const response = await fetch(`${FILE_SERVER}/small`);

  response.headers.forEach((value, key) => {
    c.header(key, value);
  });

  return c.body(response.body);
});

app.get('/large', async (c) => {
  const response = await fetch(`${FILE_SERVER}/large`);

  response.headers.forEach((value, key) => {
    c.header(key, value);
  });

  return c.body(response.body);
});

app.get('/health', (c) => c.text('OK'));

const PORT = 4000;
Bun.serve({
  fetch: app.fetch,
  port: PORT,
});

console.log(`Bun proxy running on http://localhost:${PORT}`);

