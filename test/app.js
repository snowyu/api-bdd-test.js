/* jslint node: true */
"use strict";

var express = require('express');
var bodyParser = require('body-parser')
var app = express();

module.exports = (function() {

    var server;
    var bottles = {};

    // parse application/x-www-form-urlencoded
    app.use(bodyParser.urlencoded({ extended: false }))

    // parse application/json
    app.use(bodyParser.json())

    app.get('/api/server', status);
    app.delete('/api/server', shutdown);
    app.post('/api/bottle', createBottle);
    app.head('/api/bottle/:id', isBottleExists);
    app.get('/api/bottle/:id', getBottle);
    app.put('/api/bottle/:id', putBottle);
    app.patch('/api/bottle/:id', putBottle);
    app.delete('/api/bottle/:id', delBottle);
    app.post('/api/Users/login/', login);
    app.post('/api/Users/logout/', logout);

    function login(req, res) {
      res.send({id:'xxxx'})
    }

    function logout(req, res) {
      res.sendStatus(204)
    }

    function isBottleExists(req, res) {
      if (bottles[req.params.id])
        res.sendStatus(200)
      else
        res.sendStatus(404)
    }

    function getBottle(req, res) {
      if (bottles[req.params.id])
        res.send(bottles[req.params.id])
      else
        res.sendStatus(404)
    }

    function putBottle(req, res) {
      if (bottles[req.params.id]) {
        bottles[req.params.id] = req.body
        res.send(bottles[req.params.id])
      } else
        res.sendStatus(404)
    }

    function delBottle(req, res) {
      var result;
      if (result = bottles[req.params.id]) {
        delete bottles[req.params.id]
        res.send(result)
      } else
        res.sendStatus(404)
    }

    function createBottle(req, res) {
        if (req.body.id) {
          bottles[req.body.id] = req.body
          res.send(req.body)
        } else
          res.sendStatus(500)
    }

    function shutdown(req, res) {
        res.sendStatus(202);
        req.app.emit('shutdown_request');
    }

    function status(req, res) {
        res.send({ started: req.app.get('started') });
    }

    function start(host, port, next) {
        server = app.listen(port, host, function() {
            app.on('shutdown_request', stop);
            app.set('started', new Date());
            next && next();
        });
    }

    function stop(next) {
        server && server.close(next);
    }

    return {
        start: start,
        stop: stop
    };
})();
