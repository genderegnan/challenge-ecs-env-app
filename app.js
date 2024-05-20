const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
const environment = process.env.ENVIRONMENT_NAME || 'Unknown';

app.get('/', (req, res) => {
  res.send(`Environment: ${environment}`);
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});