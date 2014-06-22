[![Build Status](https://travis-ci.org/mantacode/walkingdead.svg?branch=master)](https://travis-ci.org/mantacode/walkingdead)
[![NPM version](https://badge.fury.io/js/walkingdead.svg)](http://badge.fury.io/js/walkingdead)
[![David DM](https://david-dm.org/mantacode/walkingdead.png)](https://david-dm.org/mantacode/walkingdead.png)

![Nathan G. Romano](https://raw.github.com/mantacode/walkingdead/master/picture.jpeg)

A command-line utility for walking a list of urls with a list of user agents built with [zombie.js](https://www.npmjs.org/package/zombie "zombie")

```
$ npm install -g walkingdead
$ walkingdead < urls.txt
```

You may also use the public API for building custom walkers.

# API

## WalkingDead

The class exposes just a few public API methods as well as a few events you may listen for.  The class is derived from the  `EventEmitter` 
so you also have the same methods as the `EventEmitter`.  Please see the [EventEmitter](http://nodejs.org/api/all.html#all_class_events_eventemitter "EventEmitter") API for more information.

### WakingDead#()

```javascript
var dead = require('walkingdead')();
```

### WakingDead#(options:Object)

```javascript
var options = {agents:['walker/1.0']};
var dead = require('walkingdead')(otions);
```

### WalkingDead#walk(urlString)

This method will *walk* given the string `url`.  

```javascript
dead.walk('http://www.manta.com');
```

### WalkingDead#walk(url:String, cb:Function)

This method will *walk* the `url`.  When the walk is complete the function `cb` will be invoked
with the `url` walked, the useragent `ua` used, the [zombie](https://www.npmjs.org/package/zombie "zombie") instance, and the status of the call.

```javascript
dead.walk('http://www.manta.com', function (url, ua, zombie, status) {
  console.log('the %s was walked with the %s user agent and the status was %s', url, ua, status);
});
```

### WalkingDead#onUrl(url:String, cb:Function)

You may use th `onUrl` method as a handler for an `EventEmitter`.  Here is an examle using the `fs.createReadStream(path)`.

```javascript
var fs = require('fs');
var split = require('split');
var path '/path/to/some/file/of/urls';
fs.createReadStream(path)
  .pipe(split())
  .on('data', dead.onUrl)
  .on('error', next)
```

### Events

There are five main events.  You may attach them as you would any other kind of `EventEmitter` instance.

#### walk

A `walk` event is trigger when there are urls to be walked. When the list of urls is empty a `done` event will be triggered.

```javascript
dead.on('walk', function () {
  conosle.log('the process started'); 
});
```

#### walking

A `walking` event is triggered just before we *walk* a `url` with a the useragent `ua`.

```javascript
dead.on('walking', function (url, ua) {
  console.log('starting walking the %s with the %s user agent.', url, ua);
});
```

#### walked

A `walked` event is triggered immediately after a `url` was *walked* with the user agent `ua`.

```javascript
dead.on('walked', function (url, ua, zombie, status) {
  console.log('the %s was walked with the %s user agent and the status was %s', url, ua, status);
});
```

#### error

An `error` event is triggered whenever we encounter an `error`.

```javascript
dead.on('error', function (err, url, ua, zombie, status) {
  console.error(err);
});
```

#### done

A `done` event is triggered when the list of urls is empty.

```javascript
dead.on('done', function () {
  console.log('need more urls to walk!');
});
```

By calling `walk()` or receiving data with `onUrl()` the `walk` event will trigger and the process continues.

# Installation and Environment Setup

Install node.js (See download and install instructions here: http://nodejs.org/).

Clone this repository

    > git clone git@github.com:mantacode/walkingdead.git

cd into the directory and install the dependencies

    > cd walkingdead
    > npm install && npm shrinkwrap --dev

# Running Tests

Install coffee-script

    > npm install coffee-script -g

Tests are run using grunt.  You must first globally install the grunt-cli with npm.

    > sudo npm install -g grunt-cli

## Unit Tests

To run the tests, just run grunt

    > grunt spec

## TODO
