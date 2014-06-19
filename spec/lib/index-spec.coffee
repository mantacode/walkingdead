EventEmitter = require('events').EventEmitter

describe 'walkingdead', ->
  
  Given -> @WalkingDead = requireSubject 'lib', {
    './../package.json':
      version: 1
  }

  Then -> expect(typeof @WalkingDead).toBe 'function'

  describe '.version', ->

    When -> @version = @WalkingDead.version
    Then -> expect(@version).toEqual 1

  describe '#', ->

    Given -> @res = @WalkingDead()
    Then -> expect(@res instanceof @WalkingDead).toBe true
    And -> expect(@res instanceof EventEmitter).toBe true
    And -> expect(@res.options).toEqual agents: []

  describe '# (options:Object)', ->

    Given -> @options = agents: ['manta/1.0']
    When -> @res = @WalkingDead(@options)
    Then -> expect(@res.options).toEqual @options
  
  describe 'prototype', ->

    Given -> @wd = @WalkingDead()

    describe '#onUrl (url:String)', ->

      Given -> @url = 'http://www.manta.com'
      Given -> spyOn(@wd,'walk')
      When -> @wd.onUrl @url
      Then -> expect(@wd.walk).toHaveBeenCalledWith @url
