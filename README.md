[![Build Status](https://travis-ci.org/mantacode/walkingdead.svg?branch=master)](https://travis-ci.org/mantacode/walkingdead)
<!--[![NPM version](https://badge.fury.io/js/walkingdead.svg)](http://badge.fury.io/js/walkingdead) -->
<!--[![David DM](https://david-dm.org/mantacode/walkingdead.png)](https://david-dm.org/mantacode/walkingdead.png) -->

![Nathan G. Romano](https://raw.github.com/mantacode/walkingdead/master/picture.jpeg)

A command-line utility for walking a list of urls with a list of user agents built with [zombie.js](https://www.npmjs.org/package/zombie "zombie")

```
$ npm install -g walkingdead
$ walkingdead < urls.txt
```

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
