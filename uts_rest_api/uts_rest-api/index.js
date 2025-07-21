const express    = require('express');
const bodyParser = require('body-parser');
const app        = express();
const port       = 5000;

const router = require('./router');

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use('/api', router);

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
