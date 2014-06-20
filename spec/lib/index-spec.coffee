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
    And -> expect(@res.listeners('walk')[0]).toBe @res.onWalk

  describe '# (options:Object)', ->

    Given -> @options = agents: ['manta/1.0']
    When -> @res = @WalkingDead(@options)
    Then -> expect(@res.options).toEqual @options
  
  describe 'prototype', ->

    Given -> @url = 'http://www.manta.com'
    Given -> @wd = @WalkingDead()

    describe '#onUrl (url:String)', ->

      Given -> spyOn(@wd,'walk')
      When -> @wd.onUrl @url
      Then -> expect(@wd.walk).toHaveBeenCalledWith @url

    describe '#walk (url:String)', ->

      Given -> @paths = []
      Given -> spyOn(@paths,'push').andCallThrough()
      Given -> spyOn(@wd, 'paths').andReturn @paths
      Given -> @path = jasmine.createSpy()
      Given -> spyOn(@wd, 'path').andReturn @path
      Given -> spyOn(@wd, 'emit')
      Given -> @cb = jasmine.createSpy 'cb'
      When -> @res = @wd.walk @path, @cb
      Then -> expect(@res).toBe @wd
      And -> expect(@wd.path).toHaveBeenCalledWith @path, @cb
      And -> expect(@wd.paths).toHaveBeenCalled()
      And -> expect(@paths.push).toHaveBeenCalledWith @path
      And -> expect(@wd.emit).toHaveBeenCalledWith 'walk'

    describe '#paths', ->

      When -> @res = @wd.paths()
      Then -> expect(typeof @res).toEqual 'object'
      And -> expect(@res).toEqual []

