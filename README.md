# Cologne.js
### This is the website for the JavaScript Meetup Cologne.

Built with [NodeJS](http://nodejs.org), [CoffeeScript](http://jashkenas.github.com/coffee-script/) and [Express](http://expressjs.com).


## Install

    $ npm install
    $ coffee app.coffee

## Heroku - prerequsites

    $ boot2docker up
    $ heroku plugins:install heroku-docker

## Development

    $ heroku docker:start

## Deploy
    $ heroku docker:release
