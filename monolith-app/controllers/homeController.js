"use strict";

const User = require('../models/user');
const Cart = require('../models/cart');
const ObjectId = require('mongoose').Types.ObjectId;

exports.home_getAll = async function home_getAll(req, res) {

    var result = await Cart.findOne({}).populate('user');

    result.title = 'Hello Shop';
    result.cost = 3;
    res.render('index', result);
};