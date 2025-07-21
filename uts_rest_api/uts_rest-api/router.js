const express = require('express');
const router = express.Router();
const pool = require('./dbConnection');
const db = require('./dbConnection');
const { signupValidation, loginValidation } = require('./validation');
const { validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// === AUTH ===
router.post('/register', signupValidation, (req, res) => {
    db.query(
        `SELECT * FROM users WHERE username = ${db.escape(req.body.username)};`,
        (err, result) => {
            if (result.length) {
                return res.status(409).send({
                    message: 'The username is already exist...'
                });
            } else {
                bcrypt.hash(req.body.password, 10, (err, hash) => {
                    if (err) {
                        return res.status(500).send({ message: err });
                    }
                    db.query(
                        `INSERT INTO users (username, email, password) VALUES (?, ?, ?)`,
                        [req.body.username, req.body.email, hash],
                        (err) => {
                            if (err) {
                                return res.status(400).send({ message: err });
                            }
                            return res.status(201).send({
                                message: 'The user successfully registered...'
                            });
                        }
                    );
                });
            }
        }
    );
});

router.post('/login', loginValidation, (req, res) => {
    db.query(
        `SELECT * FROM users WHERE username = ${db.escape(req.body.username)};`,
        (err, result) => {
            if (err) throw err;
            if (!result.length) {
                return res.status(401).send({ message: 'Username incorrect...' });
            }

            bcrypt.compare(
                req.body.password,
                result[0]['password'],
                (bErr, bResult) => {
                    if (bErr) throw bErr;
                    if (bResult) {
                        const token = jwt.sign(
                            { id: result[0].id },
                            'the-super-strong-secret',
                            { expiresIn: '1h' }
                        );
                        return res.status(200).send({
                            message: 'You successfully logged in...',
                            token,
                            user: result[0]
                        });
                    }
                    return res.status(401).send({ message: 'Password is incorrect...' });
                }
            );
        }
    );
});

router.post('/get-user', signupValidation, (req, res) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(422).json({ message: 'Insert the token' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, 'the-super-strong-secret');

    db.query('SELECT * FROM users WHERE id = ?', decoded.id, (error, result) => {
        if (error) throw error;
        return res.send({
            error: false,
            data: result[0],
            message: 'Fetching account is success...'
        });
    });
});

// === INCOME CRUD ===
router.post('/item_income', (req, res) => {
    console.log('Incoming income data:', req.body); // ← tambahkan ini
    pool.getConnection((err, connection) => {
        if (err) throw err;
        const params = req.body;
        connection.query('INSERT INTO income SET ?', params, (err) => {
            connection.release();
            if (!err) {
                res.send({ message: `Income with the source ${params.source} successfully saved...` });
            } else {
                console.log("Insert income failed:", err);
                res.status(500).send({ error: 'Insert income failed' });
            }
        });
    });
});

router.get('/item_income', (req, res) => {
    pool.getConnection((err, connection) => {
        if (err) throw err;
        connection.query('SELECT * FROM income', (err, rows) => {
            connection.release();
            if (!err) {
                res.send(rows);
            } else {
                console.log("Get income failed:", err);
                res.status(500).send({ error: 'Get income failed' });
            }
        });
    });
});

router.get('/item_income/:id', (req, res) => {
    pool.getConnection((err, connection) => {
        if (err) throw err;
        connection.query('SELECT * FROM income WHERE id = ?', [req.params.id], (err, rows) => {
            connection.release();
            if (!err) {
                res.send(rows);
            } else {
                console.log("Get income by ID failed:", err);
                res.status(500).send({ error: 'Get income by ID failed' });
            }
        });
    });
});

router.put('/item_income/:id', (req, res) => {
    pool.getConnection((err, connection) => {
        if (err) throw err;
        const params = req.body;
        connection.query('UPDATE income SET ? WHERE id = ?', [params, req.params.id], (err) => {
            connection.release();
            if (!err) {
                res.send({ message: 'Income successfully updated...' });
            } else {
                console.log("Update income failed:", err);
                res.status(500).send({ error: 'Update income failed' });
            }
        });
    });
});

router.delete('/item_income/:id', (req, res) => {
    pool.getConnection((err, connection) => {
        if (err) throw err;
        connection.query('DELETE FROM income WHERE id = ?', [req.params.id], (err) => {
            connection.release();
            if (!err) {
                res.send({ message: 'Income successfully deleted...' });
            } else {
                console.log("Delete income failed:", err);
                res.status(500).send({ error: 'Delete income failed' });
            }
        });
    });
});

// === EXPENSE CRUD ===
router.post('/item_expense', (req, res) => {
    pool.getConnection((err, connection) => {
        if (err) throw err;
        const params = req.body;
        connection.query('INSERT INTO expense SET ?', params, (err) => {
            connection.release();
            if (!err) {
                res.send({ message: `Expense with the source ${params.source} successfully saved...` });
            } else {
                console.log("Insert expense failed:", err);
                res.status(500).send({ error: 'Insert expense failed' });
            }
        });
    });
});

router.get('/item_expense', (req, res) => {
    pool.getConnection((err, connection) => {
        if (err) throw err;
        connection.query('SELECT * FROM expense', (err, rows) => {
            connection.release();
            if (!err) {
                res.send(rows);
            } else {
                console.log("Get expense failed:", err);
                res.status(500).send({ error: 'Get expense failed' });
            }
        });
    });
});

router.get('/item_expense/:id', (req, res) => {
    pool.getConnection((err, connection) => {
        if (err) throw err;
        connection.query('SELECT * FROM expense WHERE id = ?', [req.params.id], (err, rows) => {
            connection.release();
            if (!err) {
                res.send(rows);
            } else {
                console.log("Get expense by ID failed:", err);
                res.status(500).send({ error: 'Get expense by ID failed' });
            }
        });
    });
});

router.put('/item_expense/:id', (req, res) => {
    pool.getConnection((err, connection) => {
        if (err) throw err;
        const params = req.body;
        connection.query('UPDATE expense SET ? WHERE id = ?', [params, req.params.id], (err) => {
            connection.release();
            if (!err) {
                res.send({ message: 'Expense successfully updated...' });
            } else {
                console.log("Update expense failed:", err);
                res.status(500).send({ error: 'Update expense failed' });
            }
        });
    });
});

router.delete('/item_expense/:id', (req, res) => {
    pool.getConnection((err, connection) => {
        if (err) throw err;
        connection.query('DELETE FROM expense WHERE id = ?', [req.params.id], (err) => {
            connection.release();
            if (!err) {
                res.send({ message: 'Expense successfully deleted...' });
            } else {
                console.log("Delete expense failed:", err);
                res.status(500).send({ error: 'Delete expense failed' });
            }
        });
    });
});

module.exports = router;
