EventEmitter = require('events').EventEmitter

describe 'WalkingDead', ->

  Given ->
    @Walker = class Walker extends EventEmitter
      constructor: (options) ->
        if not (@ instanceof Walker)
          return new Walker(options)
        @options = options
      walk: ->
      walking: ->
      onUrl: ->
  
  Given -> @WalkingDead = requireSubject 'lib/index', {
    './../package.json':
      version: 1
    './walker': @Walker
  }

  Then -> expect(typeof @WalkingDead).toBe 'function'

  describe '.version', ->

    When -> @version = @WalkingDead.version
    Then -> expect(@version).toEqual 1

  describe '#', ->

    Given -> @res = @WalkingDead()
    Then -> expect(@res instanceof @WalkingDead).toBe true
    And -> expect(@res.walker instanceof @Walker).toBe true

  describe '# (options:Object)', ->

    Given -> @options = agents: ['manta/1.0']
    When -> @res = @WalkingDead(@options)
    Then -> expect(@res.walker instanceof @Walker).toBe true
    And -> expect(@res.walker.options).toEqual @options
  
  describe 'prototype', ->

    Given -> @wd = @WalkingDead()
    [ 'onUrl',
      'walk',
      'walking'
    ].forEach (name) =>

      describe '#' + name, =>

        Given -> spyOn(@Walker.prototype[name], 'apply')
        When -> @wd[name]()
        Then -> expect(@Walker.prototype[name].apply).toHaveBeenCalled()

    Given -> @wd = @WalkingDead()
    [ 'setMaxListeners',
      'emit',
      'addListener',
      'on',
      'once',
      'removeListener',
      'removeAllListeners',
      'listeners'
    ].forEach (name) =>

      describe '#' + name, =>

        Given -> spyOn(EventEmitter.prototype[name], 'apply')
        When -> @wd[name]()
        Then -> expect(EventEmitter.prototype[name].apply).toHaveBeenCalled()
