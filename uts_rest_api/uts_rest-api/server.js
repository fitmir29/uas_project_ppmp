const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const router = require('./router');
const app = express();

app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

// Route utama
app.use('/api', router);

// Error handler
app.use((err, req, res, next) => {
    err.statusCode = err.statusCode || 500;
    err.message = err.message || 'Internal Server Error';
    res.status(err.statusCode).json({ message: err.message });
});

app.listen(5000, () => console.log('Server Berjalan di port 5000...'));
