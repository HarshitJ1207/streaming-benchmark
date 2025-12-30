const express = require('express');
const axios = require('axios');
const { pipeline } = require('stream');

const app = express();

const FILE_SERVER = 'http://localhost:8080';

const fetchAndStream = (path, req, res) => {
  axios({
    method: 'get',
    url: path,
    responseType: 'stream',
  })
    .then((response) => {
      res.writeHead(response.status, response.headers);
      pipeline(response.data, res, (err) => {
        if (err) {
          console.error('Pipeline error:', err.message);
        }
      });
    })
    .catch((error) => {
      console.error('AXIOS_ERROR', error?.code || error?.message);
      if (!res.headersSent) {
        res.status(500).send({ error: error.message });
      }
    });
};

app.get('/small', (req, res) => {
  fetchAndStream(`${FILE_SERVER}/small`, req, res);
});

app.get('/large', (req, res) => {
  fetchAndStream(`${FILE_SERVER}/large`, req, res);
});

app.get('/health', (req, res) => res.send('OK'));

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Node.js (Express + Axios) proxy running on http://localhost:${PORT}`);
});

