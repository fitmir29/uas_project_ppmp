const { check } = require('express-validator');
exports.signupValidation = [
    check('username', 'Name is required').not().isEmpty(),
    check('password', 'Password must be 6 or more character').isLength({ min:6 }),
    check('email', 'Please insert the valid email').isEmail()
]

exports.loginValidation = [
    check('username', 'Please insert username').isEmpty(),
    check('password', 'Password must be 6 or more character').isLength({ min:6 }),
]